-- ITEM A: Selecionar através de SQL os 3 gêneros mais vendidos no Brasil

SELECT 
	COUNT(sq.GenreId) AS Total,
	sq.Genre
FROM 
(
	SELECT
		ii.InvoiceId,
		ii.TrackId,
		t.GenreId,
		g.Name AS Genre
	FROM 
		invoice_items ii,
		tracks t, 
		genres g
	WHERE 
		ii.TrackId = t.TrackId AND 
		t.GenreId = g.GenreId 
) AS sq
GROUP BY
	sq.GenreId
ORDER BY 
	Total DESC
LIMIT 3

------------------------------------------------------------------------
-- ITEM B: Selecionar através de SQL o total de vendas
-- (quantidade e valor total) de cada faixa do álbum 'Mais Do Mesmo'

SELECT
	sq1.*,
	COALESCE(SUM(sq2.Quantity),0) AS Quantity,
	COALESCE(SUM(sq2.UnitPrice),0) AS Total
FROM
(
	SELECT
		t.TrackId,
		t.Name,
		t.UnitPrice
	FROM 
		tracks t,
		albums a
	WHERE 
		t.AlbumId = a.AlbumId AND
		a.Title = 'Mais Do Mesmo' 
) AS sq1

LEFT JOIN
(
	SELECT
		ii.TrackId,
		ii.UnitPrice,
		ii.Quantity
	FROM
		invoice_items ii,
		albums a,
		tracks t
	WHERE
		ii.TrackId = t.TrackId AND
		t.AlbumId = a.AlbumId AND
		a.Title = 'Mais Do Mesmo'

) AS sq2
ON 
	sq1.TrackId = sq2.TrackId
GROUP BY
	sq1.TrackId
	
	
------------------------------------------------------------------------
-- ITEM C: Selecionar através de SQL o valor total de venda por nome
-- completo do vendedor(a) em 2012
		
SELECT
	e.EmployeeId,
	e.FirstName || ' ' || e.LastName AS FullName,
	COALESCE(sq.SalesTotal,0) AS SalesTotal
FROM
	employees e 

LEFT JOIN
(
	SELECT
		e.EmployeeId,
		e.FirstName || ' ' || e.LastName AS FullName,
		SUM(i.Total) AS SalesTotal
	FROM 
		invoices i,
		customers c,
		employees e 
	WHERE 
		i.CustomerId = c.CustomerId AND
		c.SupportRepId = e.EmployeeId AND 
		i.InvoiceDate >= '2012-01-01' AND 
		i.InvoiceDate <= '2012-12-31'
	GROUP BY
		e.EmployeeId
) AS sq
ON
	e.EmployeeId = sq.EmployeeId
	
------------------------------------------------------------------------
-- ITEM D: Listar em uma única query o total de músicas, total de
-- músicas com o tipo de mídia MPEG e o total com tipo de mídia AAC
-- para cada tipo de gênero.

SELECT
	sq1.*,
	COALESCE(sq2.TotalMPEG,0) AS TotalMPEG,
	COALESCE(sq3.TotalAAC,0) AS TotalAAC
FROM
(
	SELECT
		g.Name AS GenreName,
		COUNT(t.TrackId) AS Total
	FROM 
		tracks t,
		genres g 
	WHERE
		t.GenreId = g.GenreId 
	GROUP BY 
		t.GenreId
) AS sq1

LEFT JOIN
(
	SELECT
		g.Name AS GenreName,
		COUNT(g.GenreId) AS TotalMPEG
	FROM 
		media_types mt,
		tracks t,
		genres g
	WHERE 
		t.GenreId = g.GenreId AND
		t.MediaTypeId = mt.MediaTypeId AND
		mt.Name LIKE '%MPEG%'
	GROUP BY g.GenreId
) AS sq2
ON
	sq1.GenreName = sq2.GenreName
LEFT JOIN
(
	SELECT
		g.Name AS GenreName,
		COUNT(g.GenreId) AS TotalAAC
	FROM 
		media_types mt,
		tracks t,
		genres g
	WHERE 
		t.GenreId = g.GenreId AND
		t.MediaTypeId = mt.MediaTypeId AND
		mt.Name LIKE '%AAC%'
	GROUP BY g.GenreId
) AS sq3
ON
	sq1.GenreName = sq3.GenreName