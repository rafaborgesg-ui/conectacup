// Bridge file to deploy the Edge Function via Supabase CLI.
// It imports the actual server implementation from src and starts it.
// The imported file calls Deno.serve(app.fetch) on load.
import "../../../src/supabase/functions/server/index.tsx";
