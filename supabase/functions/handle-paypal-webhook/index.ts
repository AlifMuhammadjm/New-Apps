// @ts-ignore
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
// @ts-ignore
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.7.1';

// @ts-ignore
const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
// @ts-ignore
const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

serve(async (req) => {
  try {
    // Menerima webhook data dari PayPal
    const { event } = await req.json();
    
    console.log(`Received PayPal webhook: ${JSON.stringify(event)}`);
    
    // Periksa tipe event
    if (event && event.type === 'PAYMENT.CAPTURE.COMPLETED') {
      // Inisialisasi Supabase client
      const supabase = createClient(supabaseUrl, supabaseKey);
      
      // Extract data pembayaran
      const paymentData = {
        user_id: event.resource.payer_id,
        amount: parseFloat(event.resource.amount.value),
        provider: 'paypal',
        status: 'completed',
      };
      
      // Simpan data pembayaran ke Supabase
      const { data, error } = await supabase
        .from('payments')
        .insert(paymentData);
      
      if (error) {
        console.error(`Error saving payment data: ${error.message}`);
        return new Response(JSON.stringify({ error: error.message }), {
          headers: { 'Content-Type': 'application/json' },
          status: 500,
        });
      }
      
      console.log(`Payment data saved successfully: ${JSON.stringify(data)}`);
      
      return new Response(JSON.stringify({ success: true, data }), {
        headers: { 'Content-Type': 'application/json' },
        status: 200,
      });
    }
    
    // Kembalikan respons untuk tipe event yang tidak diproses
    return new Response(JSON.stringify({ 
      message: `Event type '${event?.type || 'unknown'}' not processed` 
    }), {
      headers: { 'Content-Type': 'application/json' },
      status: 200,
    });
  } catch (error) {
    console.error(`Error processing webhook: ${error.message}`);
    
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { 'Content-Type': 'application/json' },
      status: 500,
    });
  }
}); 