
const functions = require("firebase-functions");
const stripe = require('stripe')(functions.config().stripe.testkey)
const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);

const db = admin.firestore();
const fcm = admin.messaging();

const calculateOrderAmount = (items) => {
return parseInt(items[0].id);
//    prices = [];
//    catalog = [
//        { 'id': '0', 'price': 2.99 },
//        { 'id': '1', 'price': 3.99 },
//        { 'id': '2', 'price': 4.99 },
//        { 'id': '3', 'price': 5.99 },
//        { 'id': '4', 'price': 6.99 },
//    ];
//
//    items.forEach(item => {
//        price = catalog.find(x => x.id == item.id).price;
//        prices.push(price);
//    });

//    return parseInt(items[0].id);
//    return parseInt(prices.reduce((a, b) => a + b) * 100);
};

const generateResponse = function (intent) {
    // Generate a response based on the intent's status
    switch (intent.status) {
        case 'requires_action':
            // Card requires authentication
            return {
                clientSecret: intent.client_secret,
                requiresAction: true,
                status: intent.status,
            };
        case 'requires_payment_method':
            // Card was not properly authenticated, suggest a new payment method
            return {
                error: 'Your card was denied, please provide a new payment method',
            };
        case 'succeeded':
            // Payment is complete, authentication not required
            // To cancel the payment after capture you will need to issue a Refund (https://stripe.com/docs/api/refunds).
            console.log('💰 Payment received!');
            return { clientSecret: intent.client_secret, status: intent.status };
    }
    return {
        error: 'Failed',
    };
};


exports.StripePayEndpointMethodId = functions.https.onRequest(async (req, res) => {
    const {
        paymentMethodId,
        items,
        currency,
        useStripeSdk,
    } = req.body;

    const orderAmount = calculateOrderAmount(items);

    try {
        if (paymentMethodId) {
            // Create new PaymentIntent with a PaymentMethod ID from the client.
            const params = {
                amount: orderAmount,
                confirm: true,
                return_url: 'http://kadrovic-app.tilda.ws',
                confirmation_method: 'manual',
                currency,
                payment_method: paymentMethodId,
                use_stripe_sdk: useStripeSdk,
            };
            const intent = await stripe.paymentIntents.create(params);
            // After create, if the PaymentIntent's status is succeeded, fulfill the order.
            console.log(`Intent: ${intent}`);
            return res.send(generateResponse(intent));
        }
        return res.sendStatus(400);
    } catch (e) {
        // Handle "hard declines" e.g. insufficient funds, expired card, etc
        // See https://stripe.com/docs/declines/codes for more.
        return res.send({ error: e.message });
    }
});

exports.StripePayEndpointIntentId = functions.https.onRequest(async (req, res) => {
    const {
        paymentIntentId,
    } = req.body;

    try {
        if (paymentIntentId) {
            // Confirm the PaymentIntent to finalize payment after handling a required action
            // on the client.
            const intent = await stripe.paymentIntents.confirm(paymentIntentId);
            // After confirm, if the PaymentIntent's status is succeeded, fulfill the order.
            return res.send(generateResponse(intent));
        } return res.sendStatus(400);
    } catch (e) {
        // Handle "hard declines" e.g. insufficient funds, expired card, etc
        // See https://stripe.com/docs/declines/codes for more.
        return res.send({ error: e.message });
    }
});


exports.send_chat_not = functions.firestore
  .document("Chats/{chat_id}/Messages/{message_id}")
  .onCreate((change, context) => {

    let chatRef = db.doc('Chats/'+context.params.chat_id);
    let messageRef = db.doc('Chats/'+context.params.chat_id+"/Messages/"+context.params.message_id);

      chatRef.get().then(chatSnapshot => {
        let my_getter = chatSnapshot.get('getter');
        let my_sender = chatSnapshot.get('sender');

        messageRef.get().then(messageSnapshot => {
            let user_name = chatSnapshot.get('user');
            let my_user = user_name!=my_getter ? my_sender : my_getter;
//            let my_user = +79788759240=="+79788759240" ? "+79788759241" : "+79788759240";
//            let my_user = +79788759240=="+79788759241" ? "+79788759240" : "+79788759241";
            let other_user = user_name==my_getter ? my_sender : my_getter;
            let my_message = messageSnapshot.get('message');

            let userRef = db.doc('UsersCollection/'+my_user);
            console.log('User name:', my_user);
            userRef.get().then(userSnapshot => {
                let tokenplus = userSnapshot.get('token');
                console.log('User token:', tokenplus);

                const message = {
                notification: {
                  "title": "R-Unity",
                  "body" : my_message
                },

                  data: {
                    user_id: other_user,
                    time: '2:45'
                  },
                  token: tokenplus
                };

                fcm.send(message).then((response) => {
                    console.log('Successfully sent message:', context.params.userid);
                    console.log('Successfully sent :', response);
                }).catch((error) => {console.log('Error sending message:', error);});
            });


        });


   });
});