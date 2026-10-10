# Invasons 👂

Xogo web para adestrar o oído musical: notas, intervalos harmónicos e melódicos, acordes, tonalidades e reto diario.
En galego, catalán, éuscaro e castelán.

## Ficheiros

| Ficheiro | Para que serve |
|---|---|
| `index.html` | O xogo |
| `ranking.html` | O ranking (para incrustar en cagando) |
| `config.js` | Datos de conexión con Supabase (`xogos`) — **hai que editalo** |
| `supabase.sql` | Crea a táboa `inv_scores` e a función `inv_ranking` en Supabase |
| `.nojekyll` | Só para GitHub Pages |

## Parámetros de ranking.html

`ranking.html?lang=gl&n=10&p=hoxe&v=reto`

- `lang`: gl (por defecto), ca, eu, es
- `n`: número de posicións (por defecto 10, máximo 50)
- `p`: hoxe · semana · sempre
- `v`: reto · notas · harmonicos · melodicos · acordes · tonalidades

"Hoxe" e "semana" contan coa hora de España (Europe/Madrid).
