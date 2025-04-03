import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freelancer_os/services/supabase_service.dart';

/*
Dokumen ini berisi SQL yang perlu dijalankan di konsol Supabase untuk
mengaktifkan Row Level Security (RLS) dan membuat kebijakan akses
untuk tabel-tabel dalam aplikasi Freelancer OS.

Untuk mengaktifkan RLS dan menerapkan kebijakan akses:
1. Login ke dasbor Supabase
2. Buka halaman SQL Editor
3. Salin dan jalankan SQL yang sesuai untuk setiap tabel

*/

class SupabaseSetup {
  // SQL dasar untuk membuat tabel
  static const String _createContractsTable = '''
CREATE TABLE IF NOT EXISTS public.contracts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  client_name TEXT NOT NULL,
  project_name TEXT NOT NULL,
  project_value DECIMAL(12,2) NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  status TEXT NOT NULL DEFAULT 'draft',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);
''';

  static const String _createInvoicesTable = '''
CREATE TABLE IF NOT EXISTS public.invoices (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  contract_id UUID REFERENCES public.contracts(id),
  invoice_number TEXT NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  due_date DATE NOT NULL,
  status TEXT NOT NULL DEFAULT 'unpaid',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);
''';

  static const String _createSubscriptionsTable = '''
CREATE TABLE IF NOT EXISTS public.subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  plan_type TEXT NOT NULL,
  status TEXT NOT NULL,
  start_date TIMESTAMP WITH TIME ZONE NOT NULL,
  end_date TIMESTAMP WITH TIME ZONE NOT NULL,
  payment_provider TEXT NOT NULL,
  payment_id TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);
''';

  // SQL untuk mengaktifkan RLS dan membuat kebijakan akses
  static const String _enableRLSOnContracts = '''
ALTER TABLE public.contracts ENABLE ROW LEVEL SECURITY;
''';

  static const String _createContractsAccessPolicies = '''
CREATE POLICY "User can view own contracts" 
  ON public.contracts FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "User can insert own contracts" 
  ON public.contracts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "User can update own contracts" 
  ON public.contracts FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "User can delete own contracts" 
  ON public.contracts FOR DELETE
  USING (auth.uid() = user_id);
''';

  static const String _enableRLSOnInvoices = '''
ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;
''';

  static const String _createInvoicesAccessPolicies = '''
CREATE POLICY "User can view own invoices" 
  ON public.invoices FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "User can insert own invoices" 
  ON public.invoices FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "User can update own invoices" 
  ON public.invoices FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "User can delete own invoices" 
  ON public.invoices FOR DELETE
  USING (auth.uid() = user_id);
''';

  static const String _enableRLSOnSubscriptions = '''
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
''';

  static const String _createSubscriptionsAccessPolicies = '''
CREATE POLICY "User can view own subscriptions" 
  ON public.subscriptions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "User can insert own subscriptions" 
  ON public.subscriptions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "User can update own subscriptions" 
  ON public.subscriptions FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "User can delete own subscriptions" 
  ON public.subscriptions FOR DELETE
  USING (auth.uid() = user_id);
''';

  // SQL untuk fungsi execute_sql yang memungkinkan menjalankan SQL kustom secara aman
  static const String _createExecuteSqlFunction = '''
CREATE OR REPLACE FUNCTION public.execute_sql(sql_query text)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS \$\$
DECLARE
  result JSONB;
BEGIN
  EXECUTE sql_query INTO result;
  RETURN result;
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('error', SQLERRM);
END;
\$\$;
''';

  // SQL untuk fungsi pengecekan status RLS
  static const String _createCheckRLSStatusFunction = '''
CREATE OR REPLACE FUNCTION public.check_rls_status(table_name text)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS \$\$
DECLARE
  rls_enabled BOOLEAN;
BEGIN
  SELECT relrowsecurity INTO rls_enabled
  FROM pg_class
  WHERE relname = table_name
  AND relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public');
  
  RETURN COALESCE(rls_enabled, false);
END;
\$\$;
''';

  // Semua SQL untuk setup
  static String get allSetupSQL => '''
-- 1. Membuat Tabel
$_createContractsTable

$_createInvoicesTable

$_createSubscriptionsTable

-- 2. Mengaktifkan RLS pada Tabel Contracts
$_enableRLSOnContracts

-- 3. Membuat Kebijakan Akses untuk Tabel Contracts
$_createContractsAccessPolicies

-- 4. Mengaktifkan RLS pada Tabel Invoices
$_enableRLSOnInvoices

-- 5. Membuat Kebijakan Akses untuk Tabel Invoices
$_createInvoicesAccessPolicies

-- 6. Mengaktifkan RLS pada Tabel Subscriptions
$_enableRLSOnSubscriptions

-- 7. Membuat Kebijakan Akses untuk Tabel Subscriptions
$_createSubscriptionsAccessPolicies

-- 8. Membuat Fungsi execute_sql untuk Kueri Kustom
$_createExecuteSqlFunction

-- 9. Membuat Fungsi untuk Cek Status RLS
$_createCheckRLSStatusFunction
''';

  // Menampilkan dialog dengan instruksi SQL
  static Future<void> showSetupInstructions(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Instruksi Setup Supabase'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Jalankan SQL berikut di SQL Editor Supabase untuk mengatur tabel dan keamanan:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  allSetupSQL,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Tutup'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('Salin SQL'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: allSetupSQL));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('SQL disalin ke clipboard')),
              );
            },
          ),
        ],
      ),
    );
  }
  
  // Memeriksa status RLS pada tabel tertentu
  static Future<bool> checkRLSStatus(String tableName) async {
    try {
      final result = await SupabaseService.client.rpc(
        'check_rls_status',
        params: {'table_name': tableName},
      ).execute();
      
      if (result.error != null) {
        throw result.error!.message;
      }
      
      return result.data as bool? ?? false;
    } catch (e) {
      // Jika fungsi belum dibuat, asumsikan RLS tidak aktif
      return false;
    }
  }
} 