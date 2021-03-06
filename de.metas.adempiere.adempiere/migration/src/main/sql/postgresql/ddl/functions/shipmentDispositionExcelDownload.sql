DROP FUNCTION IF EXISTS shipmentDispositionExcelDownload(TIMESTAMP With Time Zone, numeric);

CREATE OR REPLACE FUNCTION shipmentDispositionExcelDownload(
    IN M_ShipmentSchedule_Deliverydate TIMESTAMP With Time Zone,
    IN M_BPartner_ID numeric )

    RETURNS TABLE
            (
                PreparationDate_Effective TIMESTAMP With Time Zone,
                C_Bpartner_ID character varying,
                OrderDocumentNo character varying,
                OrderLine int,
                ProductName character varying ,
                ProductValue character varying,
                QtyOrdered numeric,
                QtyDelivered numeric
            )
AS

$BODY$

SELECT
    COALESCE(sps.preparationdate_override, sps.preparationdate) as preparationdate_effective,
    CONCAT(bp.value, ' ', bp.name) as C_Bpartner_ID,
    o.documentno as orderdocumentno,
    col.line::int,
    pt.name,
    pt.value,
    sps.qtyordered_tu,
    sps.qtydelivered

FROM M_ShipmentSchedule sps
         LEFT OUTER JOIN c_bpartner bp on bp.c_bpartner_id = sps.c_bpartner_id
         LEFT OUTER JOIN c_order o on o.c_order_id = sps.c_order_id
         LEFT OUTER JOIN m_product pt on pt.m_product_id = sps.m_product_id
         LEFT OUTER JOIN c_orderline col on col.c_orderline_id = sps.c_orderline_id
WHERE M_ShipmentSchedule_Deliverydate >= COALESCE(sps.preparationdate_override, sps.preparationdate)
  AND CASE WHEN M_BPartner_ID > 0 THEN bp.c_bpartner_id = M_BPartner_ID ELSE 1=1 END
  AND sps.processed = 'N'

$BODY$
    LANGUAGE sql STABLE
                 COST 100
                 ROWS 1000;
