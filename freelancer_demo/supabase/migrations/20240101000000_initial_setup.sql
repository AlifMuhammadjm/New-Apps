-- Buat tabel kontrak
CREATE TABLE IF NOT EXISTS contracts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  client_name TEXT NOT NULL,
  project_name TEXT NOT NULL,
  value DECIMAL(16, 2) NOT NULL,
  start_date TIMESTAMP WITH TIME ZONE NOT NULL,
  end_date TIMESTAMP WITH TIME ZONE NOT NULL,
  status TEXT NOT NULL,
  description TEXT NOT NULL,
  document_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Buat tabel dokumen kontrak
CREATE TABLE IF NOT EXISTS contract_documents (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  contract_id UUID NOT NULL REFERENCES contracts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  document_url TEXT NOT NULL,
  document_name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Buat tabel faktur
CREATE TABLE IF NOT EXISTS invoices (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  contract_id UUID NOT NULL REFERENCES contracts(id) ON DELETE CASCADE,
  client_name TEXT NOT NULL,
  invoice_number TEXT NOT NULL,
  amount DECIMAL(16, 2) NOT NULL,
  issue_date TIMESTAMP WITH TIME ZONE NOT NULL,
  due_date TIMESTAMP WITH TIME ZONE NOT NULL,
  payment_date TIMESTAMP WITH TIME ZONE,
  status TEXT NOT NULL,
  payment_method TEXT,
  notes TEXT,
  document_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Buat tabel klien
CREATE TABLE IF NOT EXISTS clients (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  address TEXT,
  company TEXT,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Buat fungsi untuk notifikasi faktur baru
CREATE OR REPLACE FUNCTION notify_new_invoice()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM pg_notify('new_invoice', json_build_object('user_id', NEW.user_id)::text);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Buat trigger untuk notifikasi faktur baru
CREATE TRIGGER on_new_invoice
AFTER INSERT ON invoices
FOR EACH ROW EXECUTE FUNCTION notify_new_invoice();

-- Setup policy RLS untuk kontrak
ALTER TABLE contracts ENABLE ROW LEVEL SECURITY;
CREATE POLICY user_contracts ON contracts FOR ALL USING (auth.uid() = user_id);

-- Setup policy RLS untuk dokumen kontrak
ALTER TABLE contract_documents ENABLE ROW LEVEL SECURITY;
CREATE POLICY user_contract_documents ON contract_documents FOR ALL USING (auth.uid() = user_id);

-- Setup policy RLS untuk faktur
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
CREATE POLICY user_invoices ON invoices FOR ALL USING (auth.uid() = user_id);

-- Setup policy RLS untuk klien
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
CREATE POLICY user_clients ON clients FOR ALL USING (auth.uid() = user_id);

-- Setup storage bucket untuk dokumen
INSERT INTO storage.buckets (id, name, public) VALUES ('documents', 'documents', true);

-- Setup policy RLS untuk storage
CREATE POLICY documents_policy ON storage.objects FOR ALL USING (
  bucket_id = 'documents' AND 
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Update the trigger to notify new invoice
CREATE OR REPLACE FUNCTION public.handle_new_invoice()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM pg_notify(
    'realtime:new_invoice', 
    json_build_object(
      'type', 'INSERT',
      'table', 'invoices',
      'data', json_build_object(
        'id', NEW.id,
        'user_id', NEW.user_id,
        'contract_id', NEW.contract_id,
        'invoice_number', NEW.invoice_number
      )
    )::text
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop existing trigger if exists
DROP TRIGGER IF EXISTS on_new_invoice ON invoices;

-- Create a new trigger for invoices
CREATE TRIGGER on_new_invoice
AFTER INSERT ON invoices
FOR EACH ROW EXECUTE FUNCTION handle_new_invoice(); 