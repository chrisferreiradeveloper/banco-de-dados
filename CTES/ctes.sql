

USE db_2_bim;

-- Questão 1 — Vendas concluídas
WITH vendas_concluidas AS (
    SELECT
        id_venda,
        data_venda,
        nome_cliente,
        nome_produto,
        valor_total,
        vendedor
    FROM vendas
    WHERE status_venda = 'Concluída'
)
SELECT *
FROM vendas_concluidas
ORDER BY valor_total DESC;


-- Questão 2 — Faturamento por categoria
-- Apenas categorias com faturamento total acima de R$ 10.000,00
WITH resumo_categorias AS (
    SELECT
        categoria,
        COUNT(*) AS quantidade_vendas,
        SUM(quantidade) AS total_produtos_vendidos,
        SUM(valor_total) AS faturamento_total,
        AVG(valor_total) AS valor_medio_vendas
    FROM vendas
    GROUP BY categoria
)
SELECT *
FROM resumo_categorias
WHERE faturamento_total > 10000.00
ORDER BY faturamento_total DESC;


-- Questão 3 — Desempenho dos vendedores
-- Apenas os 3 vendedores com maior valor total vendido
WITH desempenho_vendedores AS (
    SELECT
        vendedor,
        COUNT(*) AS quantidade_vendas,
        SUM(quantidade) AS total_produtos_vendidos,
        SUM(valor_total) AS valor_total_vendido,
        AVG(valor_total) AS ticket_medio
    FROM vendas
    GROUP BY vendedor
)
SELECT *
FROM desempenho_vendedores
ORDER BY valor_total_vendido DESC
LIMIT 3;


-- Questão 4 — Estados com faturamento acima da média
-- Três CTEs encadeadas: vendas_validas -> faturamento_estados -> media_faturamento
WITH vendas_validas AS (
    SELECT *
    FROM vendas
    WHERE quantidade > 0
      AND status_venda <> 'Cancelada'
),
faturamento_estados AS (
    SELECT
        estado_cliente,
        COUNT(*) AS quantidade_vendas,
        SUM(quantidade) AS total_produtos_vendidos,
        SUM(valor_total) AS faturamento_total
    FROM vendas_validas
    GROUP BY estado_cliente
),
media_faturamento AS (
    SELECT AVG(faturamento_total) AS media_geral
    FROM faturamento_estados
)
SELECT
    fe.estado_cliente,
    fe.quantidade_vendas,
    fe.total_produtos_vendidos,
    fe.faturamento_total,
    mf.media_geral,
    fe.faturamento_total - mf.media_geral AS diferenca_para_media
FROM faturamento_estados fe
CROSS JOIN media_faturamento mf
WHERE fe.faturamento_total > mf.media_geral
ORDER BY fe.faturamento_total DESC;


-- Desafio adicional — Questão 2 reescrita com subquery
SELECT
    categoria,
    quantidade_vendas,
    total_produtos_vendidos,
    faturamento_total,
    valor_medio_vendas
FROM (
    SELECT
        categoria,
        COUNT(*) AS quantidade_vendas,
        SUM(quantidade) AS total_produtos_vendidos,
        SUM(valor_total) AS faturamento_total,
        AVG(valor_total) AS valor_medio_vendas
    FROM vendas
    GROUP BY categoria
) AS resumo_categorias
WHERE faturamento_total > 10000.00
ORDER BY faturamento_total DESC;

