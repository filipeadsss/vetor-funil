// Gera public/config.js a partir das variáveis de ambiente da Vercel.
const fs = require('fs');
const url = process.env.SUPABASE_URL || '';
const key = process.env.SUPABASE_ANON_KEY || '';
fs.writeFileSync('public/config.js', 'window.VETOR_CONFIG=' + JSON.stringify({ SUPABASE_URL: url, SUPABASE_ANON_KEY: key }) + ';\n');
console.log(url ? 'config.js gerado.' : 'AVISO: SUPABASE_URL não definida; o site vai mostrar "configuração pendente".');
