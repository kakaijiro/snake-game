const compression = require("compression");
const express = require("express");
const path = require("path");

const app = express();
const port = process.env.PORT || 3000;

const publicDir = path.join(__dirname, "..", "www", "public");

app.use(compression());
app.use(express.static(publicDir));

// http://localhost:3000/
app.get("/", (_, res) => {
  res.sendFile(publicDir + "/index.html");
});

app.listen(port, () => {
  console.log(`✅Server is running on port ${port}`);
});
