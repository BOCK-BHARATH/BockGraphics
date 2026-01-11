// app.js
const express = require("express");
const cors = require("cors");
const path = require("path");
const COMPANY_CONFIG = require("./config/letterConfig");
const renderDoc = require("./utils/renderDoc");

const app = express();
app.use(cors());
app.use(express.json());

function getConfig(field) {
  const config = COMPANY_CONFIG[field];
  if (!config) throw new Error("Invalid company");
  return config;
}

/* ================= OFFER LETTER ================= */
app.post("/generate-offer", (req, res) => {
  try {
    const { name, program, issueDate, startDate, endDate, months, mode, field } =
      req.body;

    const config = getConfig(field);
    const templatePath = path.join(
      __dirname,
      "templates/offer_letter",
      config.offerTemplate
    );

    const buffer = renderDoc(templatePath, {
      XLAMAX: name,
      XVARIXBLEX: program,
      XDATEX: issueDate,
      XOX: months,
      XMODEX: mode,
      XNOXNOXXXXOXX: startDate,
      YNOXNOXXXXOXY: endDate,
    });

    res.set({
      "Content-Disposition": `attachment; filename=${config.display}_Offer_Letter.docx`,
      "Content-Type":
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    });
    res.send(buffer);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

/* ================= JOINING LETTER ================= */
app.post("/generate-joining", (req, res) => {
  try {
    const { name, program, issueDate, startDate, endDate, field } = req.body;

    const config = getConfig(field);
    const templatePath = path.join(
      __dirname,
      "templates/joining_letter",
      config.joiningTemplate
    );

    const buffer = renderDoc(templatePath, {
      XLAMAX: name,
      XVARIXBLEX: program,
      XDATEX: issueDate,
      XNOXNOXXXXOXX: startDate,
      YNOXNOXXXXOXY: endDate,
    });

    res.set({
      "Content-Disposition": `attachment; filename=${config.display}_Joining_Letter.docx`,
      "Content-Type":
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    });
    res.send(buffer);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

/* ================= COMPLETION CERTIFICATE ================= */
app.post("/generate-completion-certificate", (req, res) => {
  try {
    const {
      name,
      title,
      hours,
      specialization,
      courses,
      months,
      description,
      field,
    } = req.body;

    const config = getConfig(field);
    const templatePath = path.join(
      __dirname,
      "templates/completion_certificate",
      config.completionCertificateTemplate
    );

    const buffer = renderDoc(templatePath, {
      XLAMAX: name,
      XVARIXBLEX: title,
      XHRX: hours,
      XSPX: specialization,
      XCOX: courses,
      XMOX: months,
      XCONTENTX: description,
    });

    res.set({
      "Content-Disposition": `attachment; filename=${config.display}_Completion_Certificate.docx`,
      "Content-Type":
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    });
    res.send(buffer);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

/* ================= COMPLETION LETTER ================= */
app.post("/generate-completion-letter", (req, res) => {
  try {
    const {
      name,
      issueDate,
      work,
      proficiency,
      months,
      startDate,
      endDate,
      field,
    } = req.body;

    const config = getConfig(field);
    const templatePath = path.join(
      __dirname,
      "templates/completion_letter",
      config.completionLetterTemplate
    );

    const buffer = renderDoc(templatePath, {
      XLAMAX: name,
      XDATEX: issueDate,
      XVARIXBLEX: work,
      NOXIXON: proficiency,
      XOX: months,
      XNOXNOXXXXOXX: startDate,
      YNOXNOXXXXOXY: endDate,
    });

    res.set({
      "Content-Disposition": `attachment; filename=${config.display}_Completion_Letter.docx`,
      "Content-Type":
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    });
    res.send(buffer);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.listen(3000, () =>
  console.log("Server running on http://localhost:3000")
);
