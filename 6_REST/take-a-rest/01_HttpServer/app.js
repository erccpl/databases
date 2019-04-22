// File 01_HttpServer/app.js
// Import Express web framework
const express = require("express");
// Create main app
const app = express();

// Helper function -- print request summary
function printReqSummary(request) {
  // Display handled HTTP method and link (path + queries)
  var d = new Date();
  var n = d.toLocaleTimeString();
  console.log(`Handling ${request.method} ${request.originalUrl}, time is ` + n);
}

// GET / -- Show main page
app.get("/", function(request, response) {
  printReqSummary(request);
  // Send response to the request (here as a HTML markup)
  response.send("<h1>HTTP Server</h1><p>Go to /hello subpage!</p>");
});

// GET /hello -- Show message
app.get("/hello", function(request, response) {
  printReqSummary(request);
  response.send("<p>Anonymous message: Oh, Hi Mark!</p>");
});

app.get("/time", function(request, response) {
  printReqSummary(request);
  var d = new Date();
  var n = d.toLocaleTimeString();
  response.send("<p>Current time is:</p>" + n + "\n");
});

// Start HTTP server at port 3000
//  (type in the browser or use cURL: http://localhost:3000/)
app.listen(3000);
