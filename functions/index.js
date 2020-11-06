const functions = require('firebase-functions');
const jsdom = require("jsdom");

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
exports.getEDTDay = functions.https.onCall((data, context) => {
    let sortedData = [];
    http.get(`http://edtmobilite.wigorservices.net/WebPsDyn.aspx?Action=posETUD&serverid=h&tel=${data['firstNameLastName']}&date=${data['date']}%208:00`, res => {

        let rawData = '';
        res.on("data", chunk => rawData += chunk);
        res.on("end", () => {

            let document = new jsdom(rawData);

            document.window.document.querySelectorAll(".Ligne").forEach(elem => {
                sortedData.push({
                    debut: elem.querySelector(".Debut").innerHTML,
                    salle: elem.querySelector(".Salle").innerHTML,
                    fin: elem.querySelector(".Fin").innerHTML,
                    matiere: elem.querySelector(".Matiere").innerHTML,
                    prof: elem.querySelector(".Prof").innerHTML
                });
            })
        })
    })
    return sortedData;
})