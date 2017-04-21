
DROP DATABASE IF EXISTS productdb;
CREATE DATABASE productdb;
USE productdb;


CREATE TABLE input_static_products
(
    productId VARCHAR(50),
    productName VARCHAR(255) NOT NULL,
    pricePerUnit INTEGER NOT NULL,
    entryTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PKC_input_static_products PRIMARY KEY (productId)
);

/* write a trigger to insert productprice for each productid after insert or update of price in input_static_products */

CREATE TABLE aux_productPrices
(
    productId VARCHAR(50),
    pricePerUnit INTEGER NOT NULL,
    entryTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PKC_input_static_products PRIMARY KEY (productId,pricePerUnit)
);

CREATE TABLE input_static_stages
(
    stageId VARCHAR(50),
    stageName VARCHAR(250),
    entryTimestamp  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PKC_input_static_stages PRIMARY KEY (stageId)
);


/*Insert 1 to 100 numbers in aux_percentageDomain*/
CREATE TABLE aux_percentageDomain
(
    percentage INTEGER PRIMARY KEY
);


CREATE TABLE input_static_stageInputs
(
    stageId VARCHAR(50),
    productId VARCHAR(50),
    percentage INTEGER NOT NULL,
    entryTimestamp  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PKC_input_static_stageInputs PRIMARY KEY (stageId,productId),
    FOREIGN KEY (stageId) REFERENCES input_static_stages (stageId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (productId) REFERENCES input_static_products (productId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (percentage) REFERENCES aux_percentageDomain (percentage)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE input_static_stageOutputs
(
    stageId VARCHAR(50),
    productId VARCHAR(50),
    percentage INTEGER NOT NULL,
    entryTimestamp  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PKC_input_static_stageOutputs PRIMARY KEY (stageId,productId),
    FOREIGN KEY (stageId) REFERENCES input_static_stages (stageId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (productId) REFERENCES input_static_products (productId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (percentage) REFERENCES aux_percentageDomain (percentage)
    ON DELETE RESTRICT ON UPDATE CASCADE
);
/* write a trigger to insert all products associated with eash stage after insert on input_static_stageOutputs or input_static_stageInputs */

CREATE TABLE aux_stageProducts
(
    stageId VARCHAR(50),
    productId VARCHAR(50),
    CONSTRAINT PKC_aux_stageProducts PRIMARY KEY (stageId,productId),
    FOREIGN KEY (stageId) REFERENCES input_static_stages (stageId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (productId) REFERENCES input_static_products (productId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

/*insert movable and fixed in aux_locationTypeDomain */
CREATE TABLE aux_locationTypeDomain
(
    locationType VARCHAR (20) PRIMARY KEY
);

insert into aux_locationTypeDomain values ('Movable'),('Fixed');

CREATE TABLE input_static_produtionUnitTypes
(
    productionUnitTypeId VARCHAR(50),
    productionUnitTypeName VARCHAR(250) UNIQUE,
    locationType VARCHAR(20) NOT NULL,
    entryTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PKC_input_static_produtionUnitTypes PRIMARY KEY (productionUnitTypeId),
    FOREIGN KEY (locationType) REFERENCES aux_locationTypeDomain (locationType)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE input_static_produtionUnitTypeStages
(
    productionUnitTypeId VARCHAR(50),
    stageId VARCHAR(50),
    entryTimestamp  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PKC_input_static_produtionUnitTypeStages PRIMARY KEY (productionUnitTypeId,stageId),
    FOREIGN KEY (stageId) REFERENCES input_static_stages (stageId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (productionUnitTypeId) REFERENCES input_static_produtionUnitTypes (productionUnitTypeId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE aux_productionUnitConditionDomain
(
    productionUnitCondition VARCHAR(50) PRIMARY KEY
);

insert into aux_productionUnitConditionDomain values ('WORKING'),('IDLE'),('DAMAGED');

CREATE TABLE input_static_produtionUnits
(
    productionUnitId VARCHAR(50),
    productionUnitTypeId VARCHAR(50),
    productionUnitCondition VARCHAR(50),
    entryTimestamp  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PKC_input_static_produtionUnits PRIMARY KEY (productionUnitId),
    FOREIGN KEY (productionUnitTypeId) REFERENCES input_static_produtionUnitTypes (productionUnitTypeId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (productionUnitCondition) REFERENCES aux_productionUnitConditionDomain (productionUnitCondition)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

/* write a trigger to insert stages for each productionUnitId after insert on input_static_produtionUnits derived from input_static_produtionUnitTypeStages */
CREATE TABLE aux_productionUnitStages
(
    productionUnitId VARCHAR(50),
    stageId VARCHAR (50),
    CONSTRAINT PKC_aux_productionUnitStages PRIMARY KEY (productionUnitId,stageId),
    FOREIGN KEY (productionUnitId) REFERENCES input_static_produtionUnits (productionUnitId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (stageId) REFERENCES input_static_stages (stageId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

/* write a trigger to insert products associated with each productionUnitId after insert on input_static_produtionUnits derived from input_static_produtionUnitTypeStages and then from aux_stageProducts */

CREATE TABLE aux_productionUnitProducts
(
    productionUnitId VARCHAR(50),
    productId VARCHAR (50),
    CONSTRAINT PKC_aux_productionUnitProducts PRIMARY KEY (productionUnitId,productId),
    FOREIGN KEY (productionUnitId) REFERENCES input_static_produtionUnits (productionUnitId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (productId) REFERENCES input_static_products (productId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

/* trigger should insert values in this table for every input product for each production unit */
CREATE TABLE aux_productionUnitInputProducts
(
    productionUnitId VARCHAR(50),
    productId VARCHAR (50),
    CONSTRAINT PKC_aux_productionUnitInputProducts PRIMARY KEY (productionUnitId,productId),
    FOREIGN KEY (productionUnitId) REFERENCES input_static_produtionUnits (productionUnitId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (productId) REFERENCES input_static_products (productId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

/* trigger should insert values in this table for every output product for each production unit */
CREATE TABLE aux_productionUnitOutputProducts
(
    productionUnitId VARCHAR(50),
    productId VARCHAR (50),
    CONSTRAINT PKC_aux_productionUnitOutputProducts PRIMARY KEY (productionUnitId,productId),
    FOREIGN KEY (productionUnitId) REFERENCES input_static_produtionUnits (productionUnitId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (productId) REFERENCES input_static_products (productId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE input_static_produtionUnitCapacities
(
    productionUnitId VARCHAR(50),
    productId VARCHAR (50),
    maxStorageQuantity INTEGER NOT NULL,
    maxHoldingDuration INTEGER NOT NULL,
    entryTimestamp  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PKC_input_static_produtionUnitCapacities PRIMARY KEY (productionUnitId,productId),
    FOREIGN KEY (productionUnitId,productId) REFERENCES aux_productionUnitProducts (productionUnitId,productId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE input_static_productionUnitTypeStageResetTimes
(
    productionUnitId VARCHAR(50),
    currentStageId VARCHAR (50),
    nextStageId VARCHAR (50),
    duration INTEGER NOT NULL,
    entryTimestamp  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PKC_input_static_productionUnitTypeStageResetTimes PRIMARY KEY (productionUnitId,currentStageId,nextStageId),
    FOREIGN KEY (productionUnitId,currentStageId) REFERENCES aux_productionUnitStages (productionUnitId,stageId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (productionUnitId,nextStageId) REFERENCES aux_productionUnitStages  (productionUnitId,stageId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE input_static_productExpiries
(
    productionUnitId VARCHAR(50),
    stageId VARCHAR(50),
    productId VARCHAR(50),
    expiryTimeUnits INTEGER NOT NULL,
    entryTimestamp  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PKC_input_static_productExpiries PRIMARY KEY (productionUnitId,stageId,productId),
    FOREIGN KEY (productionUnitId,stageId) REFERENCES aux_productionUnitStages (productionUnitId,stageId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (productionUnitId,productId) REFERENCES aux_productionUnitOutputProducts (productionUnitId,productId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE input_static_transportTimeDetails
(
    sourceProductionUnitId VARCHAR(50),
    destinationProductionUnitId VARCHAR(50),
    productId VARCHAR(50),
    quantity INTEGER NOT NULL,
    timeUnitsRequired INTEGER NOT NULL,
    entryTimestamp  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PKC_input_static_transportationDetails PRIMARY KEY (sourceProductionUnitId,destinationProductionUnitId,productId,quantity),
    FOREIGN KEY (sourceProductionUnitId,productId) REFERENCES aux_productionUnitOutputProducts (productionUnitId,productId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (destinationProductionUnitId,productId) REFERENCES aux_productionUnitInputProducts (productionUnitId,productId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

/*
CREATE TABLE input_static_productionUnitLocations
(
    productionUnitId VARCHAR(50),
    currentLocationId VARCHAR(250),
    CONSTRAINT PKC_ input_static_productionUnitLocations  PRIMARY KEY (employeeId)
);
*/


CREATE TABLE input_static_employees
(
    employeeId VARCHAR(50),
    employeeName VARCHAR(50) NOT NULL,
    CONSTRAINT PKC_input_static_employees PRIMARY KEY (employeeId)
);


CREATE TABLE input_dynamic_productionOrders
(
    productionOrderId VARCHAR(50),
    productionUnitId VARCHAR(50),
    productionDetails TEXT NOT NULL,
    productionOrderDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expectedTotalProductionTime DATE NOT NULL,
    authorisedBy VARCHAR(50) NOT NULL,
    description TEXT,
    CONSTRAINT PKC_input_dynamic_productionOrders PRIMARY KEY (productionOrderId,productionUnitId),
    FOREIGN KEY (productionUnitId) REFERENCES input_static_produtionUnits (productionUnitId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (authorisedBy) REFERENCES input_static_employees (employeeId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

/* Through trigger extract productId and quantity from input_dynamic_productionOrders then refer it in input_productionOrderDetails */

CREATE TABLE input_dynamic_productionOrderDetails
(
    productionOrderId VARCHAR(50),
    productionUnitId VARCHAR(50),
    productId VARCHAR(50),
    quantity INTEGER NOT NULL,
    expectedProductionTime DATE NOT NULL,
    CONSTRAINT PKC_input_dynamic_productionOrderDetails PRIMARY KEY (productionOrderId,productionUnitId,productId,quantity,expectedProductionTime),
    FOREIGN KEY (productionOrderId,productionUnitId) REFERENCES input_dynamic_productionOrders (productionOrderId,productionUnitId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (productionUnitId,productId) REFERENCES aux_productionUnitOutputProducts (productionUnitId,productId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);
/* write a trigger which on user demand will fill up output_incompleteProductionOrderDetails table*/
CREATE TABLE output_incompleteProductionOrderDetails
(
    productionOrderId VARCHAR(50),
    productionUnitId VARCHAR(50),
    productId VARCHAR(50),
    remainingQuantity INTEGER NOT NULL,
    expectedProductionTime DATE NOT NULL,
    CONSTRAINT PKC_output_incompleteProductionOrderDetails PRIMARY KEY (productionOrderId,productionUnitId,productId,remainingQuantity,expectedProductionTime),
    FOREIGN KEY (productionOrderId,productionUnitId) REFERENCES input_dynamic_productionOrders (productionOrderId,productionUnitId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (productionUnitId,productId) REFERENCES aux_productionUnitOutputProducts (productionUnitId,productId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE input_static_productionBatchLimit
(
    batchLimit INTEGER PRIMARY KEY
);

CREATE TABLE aux_batchNumberDomain
(
    batchNo INTEGER PRIMARY KEY
);

/* write a trigger to Generate manufacturingCode using productionUnitId,productionOrderId,manufactureDate,batchNo,*/

CREATE TABLE input_dynamic_manufacturingDetails
(
    productionOrderId VARCHAR(50),
    productionUnitId VARCHAR(50),
    manufactureDate DATE NOT NULL,
    batchNo INTEGER NOT NULL,
    manufacturingCode VARCHAR(250) NOT NULL DEFAULT 0,
    entryTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PKC_input_dynamic_manufacturingDetails PRIMARY KEY (manufacturingCode),
    FOREIGN KEY (productionOrderId,productionUnitId) REFERENCES input_dynamic_productionOrders (productionOrderId,productionUnitId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (batchNo) REFERENCES aux_batchNumberDomain (batchNo)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE aux_requirementFulfillmentStatusDomain
(
    requirementFulfillmentStatus VARCHAR(10) PRIMARY KEY
);
insert into aux_requirementFulfillmentStatusDomain values ('DONE'),('NOT DONE');

CREATE TABLE input_dynamic_consumerRequirements
(
    requirementId VARCHAR(50),
    productionUnitId VARCHAR(50),
    requirementFulfillmentTime DATE NOT NULL,
    requirementFulfillmentStatus VARCHAR(10) DEFAULT 'NOT DONE',
    requirementDetails TEXT NOT NULL,
    requirementTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    description TEXT,
    CONSTRAINT PKC_input_dynamic_consumerRequirements PRIMARY KEY (requirementId,productionUnitId),
    FOREIGN KEY (requirementFulfillmentStatus) REFERENCES aux_requirementFulfillmentStatusDomain (requirementFulfillmentStatus)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (productionUnitId) REFERENCES input_static_produtionUnits (productionUnitId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

/* In future a trigger could be written to extract all the requirement details and insert in input_dynamic_consumerRequirementDetails */

CREATE TABLE input_dynamic_consumerRequirementDetails
(
    requirementId VARCHAR(50),
    productionUnitId VARCHAR(50),
    productId VARCHAR(50),
    quantity INTEGER,
    requirementFulfillmentTime DATE NOT NULL,
    requirementFulfillmentStatus VARCHAR(10) DEFAULT 'NOT DONE',
    CONSTRAINT PKC_input_dynamic_productRequirementDetails PRIMARY KEY (requirementId,productionUnitId,productId,quantity,requirementFulfillmentTime),
    FOREIGN KEY (requirementId,productionUnitId) REFERENCES input_dynamic_consumerRequirements (requirementId,productionUnitId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (requirementFulfillmentStatus) REFERENCES aux_requirementFulfillmentStatusDomain (requirementFulfillmentStatus)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (productionUnitId,productId) REFERENCES aux_productionUnitInputProducts (productionUnitId,productId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE output_incompleteConsumerRequirementDetails
(
    requirementId VARCHAR(50),
    productionUnitId VARCHAR(50),
    productId VARCHAR(50),
    quantity INTEGER,
    requirementFulfillmentTime DATE NOT NULL,
    CONSTRAINT PKC_output_incompleteConsumerRequirementDetails PRIMARY KEY (requirementId,productionUnitId,productId,quantity,requirementFulfillmentTime),
    FOREIGN KEY (requirementId,productionUnitId) REFERENCES input_dynamic_consumerRequirements (requirementId,productionUnitId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (productionUnitId,productId) REFERENCES aux_productionUnitInputProducts (productionUnitId,productId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE input_dynamic_consumerOrders
(
    consumerOrderId VARCHAR(50),
    consumerProductionUnitId VARCHAR(50),
    supplierProductionUnitId VARCHAR(50),
    expectedOrderFulfillmentTime DATE NOT NULL,
    orderDate DATE NOT NULL,
    consumerOrderDetails TEXT NOT NULL,
    requirementId VARCHAR(50) NOT NULL,
    totalAmount INTEGER NOT NULL,
    authorisedBy VARCHAR(50) NOT NULL,
    orderFulfillmentStatus VARCHAR(10) DEFAULT 'NOT DONE',
    CONSTRAINT PKC_input_dynamic_consumerOrders PRIMARY KEY (consumerOrderId,consumerProductionUnitId),
    FOREIGN KEY (supplierProductionUnitId) REFERENCES input_static_produtionUnits (productionUnitId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (requirementId,consumerProductionUnitId) REFERENCES input_dynamic_consumerRequirements (requirementId,productionUnitId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (orderFulfillmentStatus) REFERENCES aux_requirementFulfillmentStatusDomain (requirementFulfillmentStatus)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (authorisedBy) REFERENCES input_static_employees (employeeId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);


/* write a trigger to insert supplierProductionUnitId for each order inserted in input_dynamic_consumerOrders */
CREATE TABLE aux_consumerOrderSuppliers
(
    consumerOrderId VARCHAR(50),
    consumerProductionUnitId VARCHAR(50),
    supplierProductionUnitId VARCHAR(50),
    CONSTRAINT PKC_aux_consumerOrderSuppliers  PRIMARY KEY (consumerOrderId,supplierProductionUnitId),
    FOREIGN KEY (consumerOrderId,consumerProductionUnitId) REFERENCES input_dynamic_consumerOrders (consumerOrderId,consumerProductionUnitId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (supplierProductionUnitId) REFERENCES input_static_produtionUnits (productionUnitId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);


/* IN future write a trigger to extract consumerOrder details after insert on input_dynamic_consumerOrders and insert in input_dynamic_consumerOrderDetails */
CREATE TABLE input_dynamic_consumerOrderDetails
(
    consumerOrderId VARCHAR(50),
    consumerProductionUnitId VARCHAR(50),
    supplierProductionUnitId VARCHAR(50),
    productId VARCHAR(50),
    quantity INTEGER NOT NULL,
    expectedOrderFulfillmentTime DATE,
    pricePerUnit INTEGER,
    orderFulfillmentStatus VARCHAR(10) DEFAULT 'NOT DONE',
    CONSTRAINT PKC_input_dynamic_purchaseOrderDetails PRIMARY KEY (consumerOrderId,consumerProductionUnitId,productId,quantity,expectedOrderFulfillmentTime),
    FOREIGN KEY (consumerOrderId,consumerProductionUnitId) REFERENCES input_dynamic_consumerOrders (consumerOrderId,consumerProductionUnitId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (consumerOrderId,supplierProductionUnitId) REFERENCES aux_consumerOrderSuppliers (consumerOrderId,supplierProductionUnitId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (consumerProductionUnitId,productId) REFERENCES aux_productionUnitInputProducts (productionUnitId,productId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (supplierProductionUnitId,productId) REFERENCES aux_productionUnitOutputProducts (productionUnitId,productId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (productId,pricePerUnit) REFERENCES aux_productPrices (productId,pricePerUnit)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (orderFulfillmentStatus) REFERENCES aux_requirementFulfillmentStatusDomain (requirementFulfillmentStatus)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

/* write a trigger which will populate output_incompleteConsumerRequirementDetails on user demand */

CREATE TABLE output_incompleteConsumerOrderDetails
(
    consumerOrderId VARCHAR(50),
    consumerProductionUnitId VARCHAR(50),
    supplierProductionUnitId VARCHAR(50),
    productId VARCHAR(50),
    remainingQuantity INTEGER NOT NULL,
    CONSTRAINT PKC_aux_incompleteConsumerOrderDetails PRIMARY KEY (consumerOrderId,consumerProductionUnitId,productId),
    FOREIGN KEY (consumerOrderId,consumerProductionUnitId) REFERENCES input_dynamic_consumerOrders (consumerOrderId,consumerProductionUnitId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (consumerOrderId,supplierProductionUnitId) REFERENCES aux_consumerOrderSuppliers (consumerOrderId,supplierProductionUnitId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (consumerProductionUnitId,productId) REFERENCES aux_productionUnitInputProducts (productionUnitId,productId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (supplierProductionUnitId,productId) REFERENCES aux_productionUnitOutputProducts (productionUnitId,productId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE input_dynamic_supplyOrders
(
    supplyOrderId VARCHAR(50),
    supplierProductionUnitId VARCHAR(50),
    consumerProductionUnitId VARCHAR(50),
    expectedOrderFulfillmentTime DATE NOT NULL,
    supplyOrderDetails TEXT NOT NULL,
    saleDate DATE NOT NULL,
    totalAmount INTEGER NOT NULL,
    authorisedBy VARCHAR(50) NOT NULL,
    orderFulfillmentStatus VARCHAR(10) DEFAULT 'NOT DONE',
    CONSTRAINT PKC_input_dynamic_supplyOrders PRIMARY KEY (supplyOrderId,supplierProductionUnitId),
    FOREIGN KEY (orderFulfillmentStatus) REFERENCES aux_requirementFulfillmentStatusDomain (requirementFulfillmentStatus)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (supplierProductionUnitId) REFERENCES input_static_produtionUnits (productionUnitId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (consumerProductionUnitId) REFERENCES input_static_produtionUnits (productionUnitId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (authorisedBy) REFERENCES input_static_employees (employeeId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

/* write a trigger to insert in following table for each supply order*/

CREATE TABLE aux_supplyOrderConsumers
(
    supplyOrderId VARCHAR(50),
    consumerProductionUnitId VARCHAR(50),
    supplierProductionUnitId VARCHAR(50),
    CONSTRAINT PKC_aux_supplyOrderConsumers  PRIMARY KEY (supplyOrderId,consumerProductionUnitId),
    FOREIGN KEY (supplyOrderId,supplierProductionUnitId) REFERENCES input_dynamic_supplyOrders (supplyOrderId,supplierProductionUnitId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (consumerProductionUnitId) REFERENCES input_static_produtionUnits (productionUnitId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE input_dynamic_supplyOrderDetails
(
    supplyOrderId VARCHAR(50),
    supplierProductionUnitId VARCHAR(50),
    consumerProductionUnitId VARCHAR(50),
    productId VARCHAR(50),
    quantity INTEGER,
    expectedOrderFulfillmentTime DATE NOT NULL,
    pricePerUnit INTEGER NOT NULL,
    orderFulfillmentStatus VARCHAR(10) DEFAULT 'NOT DONE',
    CONSTRAINT PKC_input_dynamic_supplyOrders PRIMARY KEY (supplyOrderId,supplierProductionUnitId),
    FOREIGN KEY (supplyOrderId,supplierProductionUnitId) REFERENCES input_dynamic_supplyOrders (supplyOrderId,supplierProductionUnitId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (supplyOrderId,consumerProductionUnitId) REFERENCES aux_supplyOrderConsumers (supplyOrderId,consumerProductionUnitId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (consumerProductionUnitId,productId) REFERENCES aux_productionUnitInputProducts (productionUnitId,productId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (supplierProductionUnitId,productId) REFERENCES aux_productionUnitOutputProducts (productionUnitId,productId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (productId,pricePerUnit) REFERENCES aux_productPrices (productId,pricePerUnit)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (orderFulfillmentStatus) REFERENCES aux_requirementFulfillmentStatusDomain (requirementFulfillmentStatus)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE output_incompleteSupplyOrderDetails
(
    supplyOrderId VARCHAR(50),
    consumerProductionUnitId VARCHAR(50),
    supplierProductionUnitId VARCHAR(50),
    productId VARCHAR(50),
    remainingQuantity INTEGER NOT NULL,
    CONSTRAINT PKC_aux_incompleteSupplyOrderDetails PRIMARY KEY (supplyOrderId,supplierProductionUnitId,productId),
    FOREIGN KEY (supplyOrderId,consumerProductionUnitId) REFERENCES aux_supplyOrderConsumers (supplyOrderId,consumerProductionUnitId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (supplyOrderId,supplierProductionUnitId) REFERENCES input_dynamic_supplyOrders (supplyOrderId,supplierProductionUnitId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (consumerProductionUnitId,productId) REFERENCES aux_productionUnitInputProducts (productionUnitId,productId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (supplierProductionUnitId,productId) REFERENCES aux_productionUnitOutputProducts (productionUnitId,productId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE aux_productionUnitStatusDomain
(
    productUnitStatus VARCHAR(50) PRIMARY KEY
);

insert into aux_productionUnitStatusDomain values('IDEAL'),('BUSY'),('MAINTENANCE');

CREATE TABLE output_productionUnitStatusLog
(
    productionUnitId VARCHAR(50),
    productUnitStatus VARCHAR(50),
    statusUpdationTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PKC_output_productionUnitStatusLog PRIMARY KEY (productionUnitId,productUnitStatus,statusUpdationTime),
    FOREIGN KEY (productionUnitId) REFERENCES input_static_produtionUnits (productionUnitId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE input_static_locationDetails
(
    locationId VARCHAR (50),
    locationPath TEXT NOT NULL,
    CONSTRAINT PKC_input_static_locationDetails PRIMARY KEY (locationId)
);

CREATE TABLE input_fixedProductionUnitLocations
(
    productionUnitId VARCHAR(50),
    locationId VARCHAR (50),
    CONSTRAINT PKC_input_fixedProductionUnitLocations PRIMARY KEY (productionUnitId,locationId),
    FOREIGN KEY (productionUnitId) REFERENCES input_static_produtionUnits (productionUnitId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (locationId) REFERENCES input_static_locationDetails (locationId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

/*
CREATE TABLE aux_stageInventory
(
    productId VARCHAR(50),
    productionUnitId VARCHAR(50),
    quantity INTEGER NOT NULL,
    manufactureDate DATE NOT NULL,
    expiryDate DATE NOT NULL,
    locationId VARCHAR(50) NOT NULL,
    price INTEGER NOT NULL,
    productArrivalTime DATE NOT NULL,
    manufacturingCode VARCHAR(250) NOT NULL,
    consumerOrderId VARCHAR(50),
    supplierProductionUnitId VARCHAR(50),
    CONSTRAINT PKC_aux_stageInventory PRIMARY KEY (productId,productionUnitId,manufacturingCode,storePlaceId,expiryDate),
    CONSTRAINT CHK_isproduced CHECK (isProduced in ('Yes','No')),
    FOREIGN KEY (productId) REFERENCES input_products (productId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (stageId) REFERENCES input_stageDetails (stageId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (locationId) REFERENCES input_static_locationDetails (locationId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (manufacturingCode) REFERENCES input_manufacturingDetails (manufacturingCode)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (purchaseOrderId) REFERENCES input_purchaseOrderDetails (purchaseOrderId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);
*/
