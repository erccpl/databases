// File 02_UrlParameters/app.js
const express = require("express");
const app = express();

function printReqSummary(request) {
  console.log(`Handling ${request.method} ${request.originalUrl}`);
}

function getRandomInt(min, max) { return Math.floor(Math.random() * (max - min + 1)) + min; }

app.get("/:1/:2/:3", function(request, response) {
  printReqSummary(request);
  var rand_int = getRandomInt(1,3);
  var myval = request.params[rand_int];
  // Grab (optional) URL queries from `request.query` object
  response.send(
      `<p>One of the parameters in the paramter list is: ${myval} </p>\n`
  );
});


// GET / -- Show main page
app.get("/", function(request, response) {
  printReqSummary(request);
  response.send(
    `<h1>URL Parameters (and Queries)</h1><ul>
      <li>Show normal message (GET /hello/segment1)</li>
      <li>Show special message (GET /hello/segment1/segment2?age=NUMBER&height=NUMBER)</li>
	  <li>  where segment1, segment2 - any valid URL part</li>
	  </ul>`
  );
});

// GET /hello/:name -- Show normal message for a named person
app.get("/hello/:name", function(request, response) {
  printReqSummary(request);
  // Grab URL parameters from `request.params` object 
  response.send(`<p>Normal message for: ${request.params.name}</p>`);
});

// GET /hello/:name/:surname -- Show special message with plenty of parameters
app.get("/hello/:name/:surname", function(request, response) {
  printReqSummary(request);
  // Grab (optional) URL queries from `request.query` object
  const age = request.query.age !== null ? request.query.age : "unknown";
  const height = request.query.height !== null ? request.query.height : "unknown";
  response.send(
    `<p>Special message for: ${request.params.name} ${request.params.surname}
      (age: ${age} years, height: ${height} cm)</p>`
  );
});

app.listen(3000);
