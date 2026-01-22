const { verifyToken } = require("../auth/jwt");

function requireAuth(req, res, next) {
  const auth = req.headers.authorization || "";
  const token = auth.startsWith("Bearer ") ? auth.slice(7) : null;

  if (!token) return res.status(401).json({ error: "Missing Bearer token" });

  try {
    const decoded = verifyToken(token);
    req.user = decoded; // { sub, email, role }
    next();
  } catch (e) {
    return res.status(401).json({ error: "Invalid/expired token" });
  }
}

module.exports = { requireAuth };
