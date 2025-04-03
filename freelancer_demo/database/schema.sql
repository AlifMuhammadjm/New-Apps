-- Tabel Kontrak
CREATE TABLE contracts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users,
  project_name TEXT NOT NULL,
  client_name TEXT NOT NULL,
  value FLOAT NOT NULL,
  start_date TIMESTAMPTZ NOT NULL,
  end_date TIMESTAMPTZ NOT NULL,
  status TEXT CHECK (status IN ('active', 'completed', 'canceled')) DEFAULT 'active',
  description TEXT,
  document_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabel Faktur
CREATE TABLE invoices (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users,
  contract_id UUID REFERENCES contracts(id),
  invoice_number TEXT NOT NULL,
  client_name TEXT NOT NULL,
  amount FLOAT NOT NULL,
  issue_date TIMESTAMPTZ NOT NULL,
  due_date TIMESTAMPTZ NOT NULL,
  status TEXT CHECK (status IN ('pending', 'paid', 'canceled')) DEFAULT 'pending',
  notes TEXT,
  document_url TEXT,
  payment_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabel Klien
CREATE TABLE clients (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users,
  name TEXT NOT NULL,
  company TEXT,
  email TEXT,
  phone TEXT,
  address TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabel Notifikasi
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users,
  message TEXT NOT NULL,
  related_id UUID,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabel Escrow
CREATE TABLE escrow_transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users,
  contract_id UUID REFERENCES contracts(id),
  amount FLOAT NOT NULL,
  status TEXT CHECK (status IN ('held', 'released', 'refunded')) DEFAULT 'held',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabel Pembayaran
CREATE TABLE payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users NOT NULL,
  amount NUMERIC NOT NULL,
  method TEXT CHECK (method IN ('paypal', 'bca', 'bni', 'bri')),
  txn_id TEXT,
  status TEXT CHECK (status IN ('pending', 'completed', 'failed')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  encrypted_details BYTEA  -- Data dienkripsi dengan pgcrypto
);

-- Kebijakan Akses untuk Kontrak
CREATE POLICY "Pengguna dapat melihat kontrak mereka sendiri"
  ON contracts FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Pengguna dapat membuat kontrak mereka sendiri"
  ON contracts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Pengguna dapat memperbarui kontrak mereka sendiri"
  ON contracts FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Pengguna dapat menghapus kontrak mereka sendiri"
  ON contracts FOR DELETE
  USING (auth.uid() = user_id);

-- Kebijakan Akses untuk Faktur
CREATE POLICY "Pengguna dapat melihat faktur mereka sendiri"
  ON invoices FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Pengguna dapat membuat faktur mereka sendiri"
  ON invoices FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Pengguna dapat memperbarui faktur mereka sendiri"
  ON invoices FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Pengguna dapat menghapus faktur mereka sendiri"
  ON invoices FOR DELETE
  USING (auth.uid() = user_id);

-- Kebijakan Akses untuk Klien
CREATE POLICY "Pengguna dapat melihat klien mereka sendiri"
  ON clients FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Pengguna dapat membuat klien mereka sendiri"
  ON clients FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Pengguna dapat memperbarui klien mereka sendiri"
  ON clients FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Pengguna dapat menghapus klien mereka sendiri"
  ON clients FOR DELETE
  USING (auth.uid() = user_id);

-- Kebijakan Akses untuk Notifikasi
CREATE POLICY "Pengguna dapat melihat notifikasi mereka sendiri"
  ON notifications FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Pengguna dapat membuat notifikasi mereka sendiri"
  ON notifications FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Pengguna dapat memperbarui notifikasi mereka sendiri"
  ON notifications FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Pengguna dapat menghapus notifikasi mereka sendiri"
  ON notifications FOR DELETE
  USING (auth.uid() = user_id);

-- Kebijakan Akses untuk Escrow
CREATE POLICY "Pengguna dapat melihat escrow mereka sendiri"
  ON escrow_transactions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Pengguna dapat membuat escrow mereka sendiri"
  ON escrow_transactions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Pengguna dapat memperbarui escrow mereka sendiri"
  ON escrow_transactions FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Pengguna dapat menghapus escrow mereka sendiri"
  ON escrow_transactions FOR DELETE
  USING (auth.uid() = user_id);

-- Kebijakan Akses untuk Payments
CREATE POLICY "Pengguna dapat melihat pembayaran mereka sendiri"
  ON payments FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Pengguna dapat membuat pembayaran mereka sendiri"
  ON payments FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Pengguna dapat memperbarui pembayaran mereka sendiri"
  ON payments FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Pengguna dapat menghapus pembayaran mereka sendiri"
  ON payments FOR DELETE
  USING (auth.uid() = user_id); 