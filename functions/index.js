const functions = require("firebase-functions");
const admin = require("firebase-admin");
const crypto = require("crypto");
const Razorpay = require("razorpay");
const cors = require("cors")({ origin: true });

admin.initializeApp();
const db = admin.firestore();

// Secure credentials loaded from environment variables (Cloud Functions configuration)
const RAZORPAY_KEY_ID = process.env.RAZORPAY_KEY_ID || "rzp_test_TdqsuRubACTXNN";
const RAZORPAY_KEY_SECRET = process.env.RAZORPAY_KEY_SECRET || "40WO70t7FI0R7pprFxR8Epbx";
const RAZORPAY_WEBHOOK_SECRET = process.env.RAZORPAY_WEBHOOK_SECRET || "";

const razorpayInstance = new Razorpay({
  key_id: RAZORPAY_KEY_ID,
  key_secret: RAZORPAY_KEY_SECRET,
});

/**
 * 1. CREATE RAZORPAY ORDER (Secure Backend Endpoint)
 * Creates order on Razorpay server so secret key is never in client code.
 */
exports.createRazorpayOrder = functions.https.onRequest((req, res) => {
  return cors(req, res, async () => {
    if (req.method !== "POST") {
      return res.status(405).json({ error: "Method Not Allowed" });
    }

    try {
      const { bookingId, amount, currency = "INR" } = req.body;

      if (!bookingId || !amount) {
        return res.status(400).json({ error: "Missing bookingId or amount" });
      }

      // Convert rupees to paise
      const amountInPaise = Math.round(Number(amount) * 100);

      const options = {
        amount: amountInPaise,
        currency: currency,
        receipt: `rcpt_${bookingId.substring(0, 30)}`,
        notes: {
          bookingId: bookingId,
          source: "PYP App Backend",
        },
      };

      const order = await razorpayInstance.orders.create(options);

      return res.status(200).json({
        success: true,
        orderId: order.id,
        amount: order.amount,
        currency: order.currency,
        keyId: RAZORPAY_KEY_ID,
      });
    } catch (error) {
      console.error("Error creating Razorpay order:", error);
      return res.status(500).json({
        error: "Failed to create order on payment gateway",
        details: error.message,
      });
    }
  });
});

/**
 * 2. VERIFY RAZORPAY PAYMENT & UNLOCK CHAT (CRITICAL SECURITY ENDPOINT)
 * Verifies HMAC SHA-256 signature on backend.
 * Only after verification does it set paymentStatus="paid", chatEnabled=true,
 * and creates or links the 1:1 conversation.
 */
exports.verifyRazorpayPayment = functions.https.onRequest((req, res) => {
  return cors(req, res, async () => {
    if (req.method !== "POST") {
      return res.status(405).json({ error: "Method Not Allowed" });
    }

    try {
      const {
        bookingId,
        razorpayOrderId,
        razorpayPaymentId,
        razorpaySignature,
      } = req.body;

      if (!bookingId || !razorpayOrderId || !razorpayPaymentId || !razorpaySignature) {
        return res.status(400).json({
          error: "Missing required payment parameters (bookingId, razorpayOrderId, razorpayPaymentId, razorpaySignature)",
        });
      }

      // Backend Cryptographic Signature Verification (HMAC SHA-256)
      const generatedSignature = crypto
        .createHmac("sha256", RAZORPAY_KEY_SECRET)
        .update(`${razorpayOrderId}|${razorpayPaymentId}`)
        .digest("hex");

      const isSignatureValid = generatedSignature === razorpaySignature;

      if (!isSignatureValid) {
        console.warn(`Payment signature verification FAILED for booking: ${bookingId}`);
        return res.status(400).json({
          success: false,
          error: "Invalid payment signature. Chat unlock denied.",
        });
      }

      // 1:1 Deterministic conversation ID tied to booking
      const conversationId = `convo_bk_${bookingId.replace(/[^a-zA-Z0-9_]/g, "_")}`;

      const bookingRef = db.collection("bookings").doc(bookingId);
      const convoRef = db.collection("conversations").doc(conversationId);

      // Perform atomic idempotent update
      await db.runTransaction(async (transaction) => {
        const bookingDoc = await transaction.get(bookingRef);

        if (!bookingDoc.exists) {
          throw new Error(`Booking ${bookingId} not found`);
        }

        const bookingData = bookingDoc.data() || {};

        // Update booking to paid and unlock chat
        transaction.update(bookingRef, {
          paymentStatus: "paid",
          chatEnabled: true,
          chatEnabledAt: admin.firestore.FieldValue.serverTimestamp(),
          conversationId: conversationId,
          razorpayPaymentId: razorpayPaymentId,
          razorpayOrderId: razorpayOrderId,
          razorpaySignature: razorpaySignature,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Check if conversation already exists (Idempotent safety)
        const convoDoc = await transaction.get(convoRef);

        const customerId = bookingData.customerId || "";
        const photographerId = bookingData.photographerId || "";
        const customerName = bookingData.customerName || "Customer";
        const photographerName = bookingData.photographerName || "Photographer";

        const participantsSet = new Set([
          customerId,
          photographerId,
          ...(bookingData.customerIdentifiers || []),
          ...(bookingData.photographerIdentifiers || []),
        ]);
        const participants = Array.from(participantsSet).filter(Boolean);

        if (!convoDoc.exists) {
          transaction.set(convoRef, {
            conversationId: conversationId,
            bookingId: bookingId,
            customerId: customerId,
            photographerId: photographerId,
            customerName: customerName,
            photographerName: photographerName,
            participants: participants,
            lastMessage: "Payment verified! Chat is now enabled.",
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });

          // Add initial verified system message
          const msgRef = convoRef.collection("messages").doc();
          transaction.set(msgRef, {
            messageId: msgRef.id,
            senderId: "system",
            senderName: "PYP Concierge",
            message: "💳 Payment verified successfully! You may now chat directly to coordinate your photography session.",
            type: "system",
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        } else {
          // If conversation already exists, update timestamps and participants
          transaction.set(
            convoRef,
            {
              bookingId: bookingId,
              participants: admin.firestore.FieldValue.arrayUnion(...participants),
              updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            },
            { merge: true }
          );
        }
      });

      console.log(`Payment successfully verified and chat unlocked for booking ${bookingId}`);

      return res.status(200).json({
        success: true,
        bookingId: bookingId,
        conversationId: conversationId,
        chatEnabled: true,
        message: "Payment verified successfully. Chat enabled.",
      });
    } catch (error) {
      console.error("Error in verifyRazorpayPayment:", error);
      return res.status(500).json({
        error: "Internal server error during payment verification",
        details: error.message,
      });
    }
  });
});

/**
 * 3. RAZORPAY WEBHOOK (Automated Server-to-Server Sync)
 */
exports.razorpayWebhook = functions.https.onRequest(async (req, res) => {
  const signature = req.headers["x-razorpay-signature"];

  if (RAZORPAY_WEBHOOK_SECRET) {
    const expected = crypto
      .createHmac("sha256", RAZORPAY_WEBHOOK_SECRET)
      .update(JSON.stringify(req.body))
      .digest("hex");

    if (expected !== signature) {
      return res.status(400).send("Invalid webhook signature");
    }
  }

  const event = req.body.event;
  const payload = req.body.payload;

  if (event === "payment.captured" || event === "order.paid") {
    try {
      const paymentEntity = payload.payment ? payload.payment.entity : null;
      const notes = paymentEntity ? paymentEntity.notes : {};
      const bookingId = notes ? notes.bookingId : null;

      if (bookingId) {
        const conversationId = `convo_bk_${bookingId.replace(/[^a-zA-Z0-9_]/g, "_")}`;
        const bookingRef = db.collection("bookings").doc(bookingId);

        await bookingRef.set(
          {
            paymentStatus: "paid",
            chatEnabled: true,
            chatEnabledAt: admin.firestore.FieldValue.serverTimestamp(),
            conversationId: conversationId,
            razorpayPaymentId: paymentEntity ? paymentEntity.id : null,
            razorpayOrderId: paymentEntity ? paymentEntity.order_id : null,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true }
        );
      }
    } catch (err) {
      console.error("Webhook processing error:", err);
    }
  }

  return res.status(200).json({ status: "ok" });
});
