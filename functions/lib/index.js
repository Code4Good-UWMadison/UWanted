"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");
admin.initializeApp();
const db = admin.firestore();
const fcm = admin.messaging();
// export const sendToTopic = functions.firestore
//   .document('puppies/{puppyId}')
//   .onCreate(async snapshot => {
//     const puppy = snapshot.data();
//     const payload: admin.messaging.MessagingPayload = {
//       notification: {
//         title: 'New Puppy!',
//         body: `${puppy.name} is ready for adoption`,
//         icon: '',
//         click_action: 'FLUTTER_NOTIFICATION_CLICK'
//       }
//     };
//     return fcm.sendToTopic('puppies', payload);
//   });
exports.sendToDevice = functions.firestore
    .document('tasks/{taskId}/applicants/{applicantId}')
    .onCreate((snapshot, context) => __awaiter(this, void 0, void 0, function* () {
    console.log("taskID:", context.params.taskId);
    console.log("appId:", context.params.applicantId);
    const userIdQuery = yield db.collection('tasks').doc(context.params.taskId).get();
    const userId = userIdQuery.data()['userId'];
    const applicantId = snapshot.id;
    console.log("start find token: ", userId);
    const querySnapshot = yield db
        .collection('users')
        .doc(userId)
        .collection('tokens')
        .get();
    const nameQuery = yield db
        .collection('users')
        .doc(applicantId)
        .get();
    console.log("finish find token");
    const tokens = querySnapshot.docs.map(snap => snap.id);
    const payload = {
        notification: {
            title: 'New Person Comes',
            body: `Your request got a response from ${nameQuery.data()['name']}`,
            // icon: '',
            click_action: 'FLUTTER_NOTIFICATION_CLICK'
        }
    };
    return fcm.sendToDevice(tokens, payload);
}));
const gmailEmail = functions.config().gmail.email;
const gmailPassword = functions.config().gmail.password;
const mailTransport = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: gmailEmail,
        pass: gmailPassword,
    },
});
const APP_NAME = 'UWanted';
exports.sendNotifyEmail = functions.firestore
    .document('tasks/{taskId}/applicants/{applicantId}')
    .onCreate((snapshot, context) => __awaiter(this, void 0, void 0, function* () {
    const userIdQuery = yield db.collection('tasks').doc(context.params.taskId).get();
    const userId = userIdQuery.data()['userId'];
    const applicantId = snapshot.id;
    const nameQuery = yield db
        .collection('users')
        .doc(applicantId)
        .get();
    const nameQuery2 = yield db
        .collection('users')
        .doc(userId)
        .get();
    const email = yield findUserEmail(userId); // The email of the user.
    const appName = yield nameQuery.data()['name']; // The display name of the user.
    const userName = yield nameQuery2.data()['name'];
    return sendHelper(email, appName, userName);
}));
function findUserEmail(uid) {
    return __awaiter(this, void 0, void 0, function* () {
        console.log('Finding User Email');
        return new Promise((resolve, reject) => {
            admin.auth().getUser(uid)
                .then(userRecord => {
                console.log("JSON: ", userRecord.toJSON());
                console.log("email: ", userRecord.toJSON()['email']);
                resolve(userRecord.toJSON()['email']); // WARNING! Filter the json first, it contains password hash!
            })
                .catch(error => {
                console.error('Error fetching user data:', error);
                reject({ status: 'error', code: 500, error });
            });
        });
    });
}
// Sends a noti email to the given user.
function sendHelper(email, appName, userName) {
    return __awaiter(this, void 0, void 0, function* () {
        console.log("Sending User Msg");
        const mailOptions = {
            from: `${APP_NAME} <noreply@firebase.com>`,
            to: email,
            subject: "",
            text: "",
        };
        // The user subscribed to the newsletter.
        mailOptions.subject = `Your post just got one response!`;
        mailOptions.text = `Hey ${userName || ''}! Your post just got one response from ${appName || ''}`;
        yield mailTransport.sendMail(mailOptions);
        console.log('New notification email sent to:', email);
        return null;
    });
}
// [START sendWelcomeEmail]
/**
 * Sends a welcome email to new user.
 */
// [START onCreateTrigger]
exports.sendWelcomeEmail = functions.firestore
    .document('users/{userId}')
    .onCreate((snapshot, context) => __awaiter(this, void 0, void 0, function* () {
    // [END onCreateTrigger]
    // [START eventAttributes]
    const userId = snapshot.id;
    const email = yield findUserEmail(userId); // The email of the user.
    // [END eventAttributes]
    return sendWelcomeEmail(email);
}));
// [END sendWelcomeEmail]
// [START sendByeEmail]
/**
 * Send an account deleted email confirmation to users who delete their accounts.
 */
// [START onDeleteTrigger]
exports.sendByeEmail = functions.auth.user().onDelete((user) => {
    // [END onDeleteTrigger]
    const email = user.email;
    const displayName = user.displayName;
    return sendGoodbyeEmail(email, displayName);
});
// [END sendByeEmail]
// Sends a welcome email to the given user.
function sendWelcomeEmail(email) {
    return __awaiter(this, void 0, void 0, function* () {
        const mailOptions = {
            from: `${APP_NAME} <noreply@firebase.com>`,
            to: email,
            subject: "",
            text: "",
        };
        // The user subscribed to the newsletter.
        mailOptions.subject = `Welcome to ${APP_NAME}!`;
        mailOptions.text = `Hey there! Welcome to ${APP_NAME}. I hope you will enjoy our service.`;
        yield mailTransport.sendMail(mailOptions);
        console.log('New welcome email sent to:', email);
        return null;
    });
}
// Sends a goodbye email to the given user.
function sendGoodbyeEmail(email, displayName) {
    return __awaiter(this, void 0, void 0, function* () {
        const mailOptions = {
            from: `${APP_NAME} <noreply@firebase.com>`,
            to: email,
            subject: "",
            text: "",
        };
        // The user unsubscribed to the newsletter.
        mailOptions.subject = `Bye!`;
        mailOptions.text = `Hey ${displayName || ''}!, We confirm that we have deleted your ${APP_NAME} account.`;
        yield mailTransport.sendMail(mailOptions);
        console.log('Account deletion confirmation email sent to:', email);
        return null;
    });
}
//# sourceMappingURL=index.js.map