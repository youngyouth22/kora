/// Centralised endpoints and timeout constants for the Kora Skin Coach AI
/// Backend deployed on Render.
abstract final class ApiEndpoints {
  /// Default base URL of the Kora Skin Coach AI backend on Render.
  static const String defaultBaseUrl = String.fromEnvironment(
    'KORA_AI_BASE_URL',
    defaultValue: 'https://kora-skin-coach.onrender.com',
  );

  /// Compile-time Mastra API secret override via `--dart-define`.
  static const String compileTimeApiSecret = String.fromEnvironment(
    'MASTRA_API_SECRET',
  );

  /// Known default secret for Render Mastra AI backend.
  static const String defaultApiSecret =
      '8ece5b36ff5672024e4b3d3693aa5e48556322ffc747e9ae4e9c932a230b53da';

  /// YouCam (Perfect Corp) API base URL.
  static const String youcamBaseUrl = String.fromEnvironment(
    'YOUCAM_BASE_URL',
    defaultValue: 'https://yce-api-01.makeupar.com',
  );

  /// YouCam API key for skin analysis telemetry.
  static const String youcamApiKey = String.fromEnvironment(
    'YOUCAM_API_KEY',
    defaultValue:
        'sk-EYW52wC3Ue-ylVdouAJxfILUI-V_FXv4rz6ovLAZgjzZfdOxyM2QzDuKuX730CKg',
  );

  /// Supabase project base URL hosting Edge Functions.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://mxgumftalavoxmaqutjr.supabase.co',
  );

  /// Google OAuth Web Client ID (Server Client ID) required on Android by
  /// Google Credential Manager / Google Sign-In to obtain an ID token for
  /// Supabase authentication.
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );

  /// Edge function path for secure YouCam skin analysis orchestration and
  /// private bucket storage.
  static const String scanFunction = '/functions/v1/scan';

  /// Public health check endpoint (GET, no authentication required).
  static const String health = '/health';

  /// Generates a personalized AI SkinReport from a normalized scan (POST).
  static const String skinReport = '/skin-report';

  /// Normalizes OCR/barcode input, fetches INCI/SERP/YouTube, and scores
  /// compatibility with user profile via skincareScanWorkflow (POST).
  static const String scanProduct = '/scan-product';

  /// Interactive Kora AI Coach conversation with red-flag safety gate (POST).
  static const String coachChat = '/api/agents/skinCoach/generate';

  /// Connection timeout in milliseconds for AI backend requests (30s).
  static const int connectTimeoutMs = 30000;

  /// Extended receive timeout (120s) for LLM + SERP multi-agent workflows.
  static const int receiveTimeoutMs = 120000;

  /// Send timeout in milliseconds for AI backend requests (30s).
  static const int sendTimeoutMs = 30000;
}
