/// Environment configuration.
///
/// For production, load these from --dart-define or a secure source.
/// Example:
///   flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co \
///               --dart-define=SUPABASE_ANON_KEY=eyJ... \
///               --dart-define=OPENAI_API_KEY=sk-...
class Env {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static const openAiApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );

  static const openAiBaseUrl = String.fromEnvironment(
    'OPENAI_BASE_URL',
    defaultValue: 'https://api.openai.com/v1',
  );

  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static bool get hasOpenAi => openAiApiKey.isNotEmpty;
}
