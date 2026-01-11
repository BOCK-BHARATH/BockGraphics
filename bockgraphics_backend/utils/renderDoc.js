// utils/renderDoc.js
const fs = require("fs");
const PizZip = require("pizzip");
const Docxtemplater = require("docxtemplater");

module.exports = function renderDoc(templatePath, data) {
  const content = fs.readFileSync(templatePath, "binary");
  const zip = new PizZip(content);

  const doc = new Docxtemplater(zip, {
    paragraphLoop: true,
    linebreaks: true,
    delimiters: { start: "{", end: "}" },
  });

  doc.render(data);

  return doc.getZip().generate({
    type: "nodebuffer",
    compression: "DEFLATE",
  });
};
