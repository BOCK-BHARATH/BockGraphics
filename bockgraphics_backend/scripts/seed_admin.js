require("dotenv").config();
const bcrypt = require("bcryptjs");
const { supabase } = require("../db/supabase");

async function seed() {
  const email = "admin@bock.com";
  const password = "Bockpass123@"; // change later

  const password_hash = await bcrypt.hash(password, 12);

  const { data, error } = await supabase
    .from("app_users")
    .upsert(
      {
        email: email.toLowerCase(),
        password_hash,
        role: "admin",
        is_active: true,
      },
      { onConflict: "email" }
    )
    .select();

  if (error) throw error;

  console.log("Seeded admin:", email, "password:", password);
  console.log(data);
}

seed().catch((e) => {
  console.error(e);
  process.exit(1);
});
