const express = require("express");
const bcrypt = require("bcryptjs");
const { supabase } = require("../db/supabase");
const { signToken } = require("../auth/jwt");

const router = express.Router();

/**
 * POST /auth/login
 * body: { email, password }
 */
router.post("/login", async (req, res) => {
  try {
    const email = (req.body.email || "").trim().toLowerCase();
    const password = req.body.password || "";

    if (!email || !password) {
      return res.status(400).json({ error: "Email and password required" });
    }

    const { data: user, error } = await supabase
      .from("app_users")
      .select("id,email,password_hash,role,is_active")
      .eq("email", email)
      .single();

    if (error || !user) return res.status(401).json({ error: "Invalid login" });
    if (!user.is_active) return res.status(403).json({ error: "User disabled" });

    const ok = await bcrypt.compare(password, user.password_hash);
    if (!ok) return res.status(401).json({ error: "Invalid login" });

    const token = signToken({
      sub: user.id,
      email: user.email,
      role: user.role,
    });

    return res.json({
      token,
      user: { id: user.id, email: user.email, role: user.role },
    });
  } catch (e) {
    return res.status(500).json({ error: "Login failed" });
  }
});

module.exports = router;
