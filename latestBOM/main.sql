SELECT 
    orgn.ORGANIZATION_CODE AS "Organization",
    p_item.ITEM_NUMBER AS "Parent Item Number",
    c_item.ITEM_NUMBER AS "Component Item Number",
    comp.COMPONENT_QUANTITY AS "Component Quantity",
    
    (SELECT LISTAGG(COMPONENT_REFERENCE_DESIGNATOR, ',') WITHIN GROUP (ORDER BY COMPONENT_REFERENCE_DESIGNATOR)
     FROM EGP_REFERENCE_DESIGNATORS
     WHERE COMPONENT_SEQUENCE_ID = comp.COMPONENT_SEQUENCE_ID) AS "Reference Designators",
     
    c_rev.REVISION AS "Component Item Revision",
    
    NULL AS "Parent Base Quantity", 
    
    comp.ATTRIBUTE_NUMBER2 AS "Scrap Rate", 
    comp.ATTRIBUTE2 AS "Alt Item Group",      
    comp.ATTRIBUTE_NUMBER3 AS "Priority",            
    comp.ATTRIBUTE_NUMBER4 AS "Usage Rate",          
    comp.ATTRIBUTE3 AS "Strategy",            
    comp.ATTRIBUTE4 AS "Discontinue Group",   
    comp.ATTRIBUTE5 AS "Follow Up Group",     
    comp.ATTRIBUTE6 AS "Bulk Material",       
    
    NULL AS "Co-Product", 
    
    comp.ITEM_NUM AS "Component Sequence",
    c_item.PRIMARY_UOM_CODE AS "Component UOM",
    
    comp.EFFECTIVITY_DATE AS "Effectivity Date",
    
    p_rev.REVISION AS "Parent item Revision"

FROM EGP_SYSTEM_ITEMS_B p_item

INNER JOIN INV_ORGANIZATION_DEFINITIONS_V orgn 
    ON p_item.ORGANIZATION_ID = orgn.ORGANIZATION_ID
    
INNER JOIN EGP_STRUCTURES_B struct 
    ON p_item.INVENTORY_ITEM_ID = TO_NUMBER(struct.PK1_VALUE)
    AND p_item.ORGANIZATION_ID = TO_NUMBER(struct.PK2_VALUE)
    AND struct.EFFECTIVITY_CONTROL = 1
    
INNER JOIN EGP_COMPONENTS_B comp 
    ON struct.COMMON_BILL_SEQUENCE_ID = comp.BILL_SEQUENCE_ID
    AND comp.OBJ_NAME = 'EGO_ITEM'
    
INNER JOIN EGP_SYSTEM_ITEMS_B c_item 
    ON TO_NUMBER(comp.PK1_VALUE) = c_item.INVENTORY_ITEM_ID 
    AND TO_NUMBER(comp.PK2_VALUE) = c_item.ORGANIZATION_ID

-- Simple join to fetch currently active revisions 
LEFT JOIN EGP_ITEM_REVISIONS_B p_rev 
    ON p_item.INVENTORY_ITEM_ID = p_rev.INVENTORY_ITEM_ID 
    AND p_item.ORGANIZATION_ID = p_rev.ORGANIZATION_ID
    AND p_rev.EFFECTIVITY_DATE <= SYSDATE 
    AND (p_rev.END_EFFECTIVITY_DATE IS NULL OR p_rev.END_EFFECTIVITY_DATE > SYSDATE)
    
LEFT JOIN EGP_ITEM_REVISIONS_B c_rev 
    ON c_item.INVENTORY_ITEM_ID = c_rev.INVENTORY_ITEM_ID 
    AND c_item.ORGANIZATION_ID = c_rev.ORGANIZATION_ID
    AND c_rev.EFFECTIVITY_DATE <= SYSDATE 
    AND (c_rev.END_EFFECTIVITY_DATE IS NULL OR c_rev.END_EFFECTIVITY_DATE > SYSDATE)

WHERE c_item.ITEM_NUMBER = '142301000633' -- Swap this to test different items

-- new revs added to the main sql query