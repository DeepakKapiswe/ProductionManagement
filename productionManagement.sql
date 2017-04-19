
DROP DATABASE IF EXISTS productdb;
CREATE DATABASE productdb;
USE productdb;

/*DROP TABLE IF EXISTS aux_stageInventory;
DROP TABLE IF EXISTS input_storageDetails;
DROP TABLE IF EXISTS input_purchaseOrderDetails;
DROP TABLE IF EXISTS input_purchaseOrders;
DROP TABLE IF EXISTS input_manufacturingDetails;
DROP TABLE IF EXISTS aux_batchNumberDomain;
DROP TABLE IF EXISTS input_productionBatchLimit;
DROP TABLE IF EXISTS input_productionOrderDetails;
DROP TABLE IF EXISTS input_productionOrders;
DROP TABLE IF EXISTS input_employees;
DROP TABLE IF EXISTS input_transportTimeDetails;
DROP TABLE IF EXISTS input_productExpiries;
DROP TABLE IF EXISTS input_productionUnitResetTime;
DROP TABLE IF EXISTS input_productManufacturingTime;
DROP TABLE IF EXISTS input_productionRawMaterialDependencies;
DROP TABLE IF EXISTS input_productionUnitProductGroups;
DROP TABLE IF EXISTS aux_productGroups;
DROP TABLE IF EXISTS input_productionProductGroupDetails;
DROP TABLE IF EXISTS input_productionUnits;
DROP TABLE IF EXISTS input_stageDetails;
DROP TABLE IF EXISTS input_products;*/

CREATE TABLE input_products
(
    productId VARCHAR(50),
    productName VARCHAR(255) NOT NULL,
    pricePerUnit INTEGER NOT NULL,
    CONSTRAINT PKC_input_products PRIMARY KEY (productId)
);

CREATE TABLE input_stageDetails
(
    stageId VARCHAR(50),
    stageName TEXT NOT NULL,
    stageLocation TEXT NOT NULL,
    CONSTRAINT PKC_input_stageDetails PRIMARY KEY (stageId)
);

CREATE TABLE input_productionUnits
(
    productionUnitId VARCHAR(50),
    stageId VARCHAR(50),
    maximumManufacturingLimit VARCHAR(50),
    minimumManufacturingLimit VARCHAR(50),
    CONSTRAINT PKC_input_productionUnits PRIMARY KEY (stageId,productionUnitId),
    FOREIGN KEY (stageId) REFERENCES input_stageDetails (stageId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE input_productionProductGroupDetails
(
    productGroupId VARCHAR(50),
    manufacturedProductId VARCHAR(50),
    proportion FLOAT NOT NULL,
    CONSTRAINT PKC_input_productionProductGroupDetails PRIMARY KEY (productGroupId,manufacturedProductId),
    FOREIGN KEY (manufacturedProductId) REFERENCES input_products (productId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

/*Write trigger to insert in aux_productGroups after insertion on input_productionProductGroupDetails*/
CREATE TABLE aux_productGroups
(
    productGroupId VARCHAR(50) PRIMARY KEY
);

CREATE TABLE input_productionUnitProductGroups
(
    stageId VARCHAR(50),
    productionUnitId VARCHAR(50),
    productGroupId VARCHAR(50),
    CONSTRAINT PKC_aux_productionUnitProductGroups PRIMARY KEY (stageId,productionUnitId,productGroupId),
    FOREIGN KEY (stageId,productionUnitId) REFERENCES input_productionUnits (stageId,productionUnitId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (productGroupId) REFERENCES aux_productGroups (productGroupId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

/* write a trigger to insert on aux_stageProductionProducts after every insert on input_productionUnitProductGroups for  same stageId with each member productId */
CREATE TABLE aux_stageProductionProducts
(
    productionStageId VARCHAR(50),
    manufacturedProductId VARCHAR(50),
    CONSTRAINT PKC_aux_stageProductionProducts PRIMARY KEY (productionStageId,manufacturedProductId),
    FOREIGN KEY (productionStageId) REFERENCES input_stageDetails (stageId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (manufacturedProductId) REFERENCES input_products (productId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE input_productionRawMaterialDependencies
(
    stageId VARCHAR(50),
    productionUnitId VARCHAR(50),
    productGroupId VARCHAR(50),
    ingredientProductId VARCHAR(50),
    proportion FLOAT NOT NULL,
    CONSTRAINT PKC_input_productionRawMaterialDependencies PRIMARY KEY (stageId,productionUnitId,productGroupId,ingredientProductId),
    FOREIGN KEY (stageId,productionUnitId,productGroupId) REFERENCES input_productionUnitProductGroups (stageId,productionUnitId,productGroupId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (ingredientProductId) REFERENCES input_products (productId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE input_productManufacturingTime
(
    stageId VARCHAR(50),
    productionUnitId VARCHAR(50),
    productGroupId VARCHAR(50),
    quantity INTEGER,
    manufacturingTimeRequired INTEGER NOT NULL,
    CONSTRAINT PKC_input_productManufacturingTime PRIMARY KEY (stageId,productionUnitId,productGroupId,quantity),
    FOREIGN KEY (stageId,productionUnitId,productGroupId) REFERENCES input_productionUnitProductGroups (stageId,productionUnitId,productGroupId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE input_productionUnitResetTime
(
    stageId VARCHAR(50),
    productionUnitId VARCHAR(50),
    currentProductGroupId VARCHAR(50),
    nextProductGroupId VARCHAR(50),
    resetTime INTEGER NOT NULL,
    CONSTRAINT PKC_input_productionUnitResetTime PRIMARY KEY (stageId,productionUnitId,currentProductGroupId,nextProductGroupId),
    FOREIGN KEY (stageId,productionUnitId,currentProductGroupId) REFERENCES input_productionUnitProductGroups (stageId,productionUnitId,productGroupId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (stageId,productionUnitId,nextProductGroupId) REFERENCES input_productionUnitProductGroups (stageId,productionUnitId,productGroupId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE input_productExpiries
(
    stageId VARCHAR(50),
    productionUnitId VARCHAR(50),
    productGroupId VARCHAR(50),
    productId VARCHAR(50),
    expiryTimeUnits INTEGER NOT NULL,
    CONSTRAINT PKC_input_productExpiries PRIMARY KEY (stageId,productionUnitId,productGroupId,productId),
    FOREIGN KEY (stageId,productionUnitId,productGroupId) REFERENCES input_productionUnitProductGroups (stageId,productionUnitId,productGroupId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (productGroupId,productId) REFERENCES input_productionProductGroupDetails (productGroupId,manufacturedProductId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE input_transportTimeDetails /*static -dynamic inputs*/
(
    sourceStageId VARCHAR(50),
    destinationStageId VARCHAR(50),
    productId VARCHAR(50),
    quantity INTEGER NOT NULL,
    timeUnitsRequired INTEGER NOT NULL,
    CONSTRAINT PKC_input_transportationDetails PRIMARY KEY (sourceStageId,destinationStageId,productId,quantity),
    FOREIGN KEY (sourceStageId) REFERENCES input_stageDetails (stageId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (destinationStageId) REFERENCES input_stageDetails (stageId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (productId) REFERENCES input_products (productId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE input_employees
(
    employeeId VARCHAR(50),
    stageId VARCHAR(50),
    employeeName VARCHAR(50) NOT NULL,
    CONSTRAINT PKC_input_employees PRIMARY KEY (employeeId,stageId)
    FOREIGN KEY (stageId) REFERENCES input_stageDetails (stageId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
);

CREATE TABLE input_productionOrders
(
    productionOrderId VARCHAR(50),
    productionStageId VARCHAR(50),
    productionDetails TEXT NOT NULL,
    expectedTotalProductionTime DATE NOT NULL,
    authorisedBy VARCHAR(50) NOT NULL,
    description TEXT,
    CONSTRAINT PKC_input_productionOrders PRIMARY KEY (productionOrderId,stageId),
    FOREIGN KEY (productionOrderId) REFERENCES input_stageDetails (stageId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (authorisedBy,productionStageId) REFERENCES input_employees (employeeId,stageId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

/* Through trigger extract productId and quantity from input_productionOrders then refer it in input_productionOrderDetails */

CREATE TABLE input_productionOrderDetails
(
    productionOrderId VARCHAR(50),
    productionStageId VARCHAR(50),
    productId VARCHAR(50),
    quantity INTEGER NOT NULL,
    expectedProductionTime DATE NOT NULL,
    CONSTRAINT PKC_input_productionOrderDetails PRIMARY KEY (productionOrderId,productId,quantity,expectedProductionTime),
    FOREIGN KEY (productionOrderId,productionStageId) REFERENCES input_productionOrders (productionOrderId,productionStageId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (productionStageId,productId) REFERENCES aux_stageProductionProducts (productionStageId,manufacturedProductId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);


CREATE TABLE aux_incompleteProductionOrderDetails /*output*/
(
    productionOrderId VARCHAR(50),
    productionStageId VARCHAR(50),
    productId VARCHAR(50),
    remainingQuantity INTEGER NOT NULL,
    expectedProductionTime DATE NOT NULL,
    CONSTRAINT PKC_input_productionOrderDetails PRIMARY KEY (productionOrderId,productionStageId,productId,remainingQuantity,expectedProductionTime),
    FOREIGN KEY (productionOrderId,productionStageId) REFERENCES input_productionOrders (productionOrderId,productionStageId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (productionStageId,productId) REFERENCES aux_stageProductionProducts (productionStageId,manufacturedProductId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);



CREATE TABLE input_productionBatchLimit
(
    batchLimit INTEGER PRIMARY KEY
);

CREATE TABLE aux_batchNumberDomain
(
    batchNo INTEGER PRIMARY KEY
);


/* Generate manufacturingCode using stageId,productionUnitId,manufactureDate,batchNo,*/
CREATE TABLE input_manufacturingDetails
(
    productionOrderId VARCHAR(50),
    stageId VARCHAR(50),
    productionUnitId VARCHAR(50),
    manufactureDate DATE NOT NULL,
    batchNo INTEGER NOT NULL,
    manufacturingCode VARCHAR(250) NOT NULL DEFAULT 0,
    CONSTRAINT PKC_input_manufacturingDetails PRIMARY KEY (manufacturingCode),
    FOREIGN KEY (productionOrderId,stageId) REFERENCES input_productionOrders (productionOrderId,stageId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (stageId,productionUnitId) REFERENCES input_productionUnits (stageId,productionUnitId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (batchNo) REFERENCES aux_batchNumberDomain (batchNo)
    ON DELETE RESTRICT ON UPDATE CASCADE
);


CREATE TABLE input_productRequirements
(
    requirementId VARCHAR(50),
    stageId VARCHAR(50),
    requirementFulfillmentTime DATE NOT NULL,
    requirementFulfillmentStatus VARCHAR(10) DEFAULT 'NOT DONE',
    CONSTRAINT PKC_input_productRequirements PRIMARY KEY (requirementId,stageId),
    CONSTRAINT CHK_requirementFulfillmentStatus CHECK (requirementFulfillmentStatus in ('DONE','NOT DONE')),
    FOREIGN KEY (stageId) REFERENCES input_stageDetails (stageId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE input_productRequirementDetails
(
    requirementId VARCHAR(50),
    stageId VARCHAR(50),
    productId VARCHAR(50),
    quantity INTEGER,
    requirementFulfillmentTime DATE NOT NULL,
    requirementFulfillmentStatus VARCHAR(10) DEFAULT 'NOT DONE',
    CONSTRAINT PKC_input_productRequirementDetails PRIMARY KEY (requirementId,stageId,productId,quantity,requirementFulfillmentTime),
    CONSTRAINT CHK_requirementFulfillmentStatus CHECK (requirementFulfillmentStatus in ('DONE','NOT DONE')),
    FOREIGN KEY (requirementId,stageId) REFERENCES input_productRequirements (requirementId,stageId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (productId) REFERENCES input_products (productId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE aux_incompleteProductRequirementDetails
(
    requirementId VARCHAR(50),
    stageId VARCHAR(50),
    productId VARCHAR(50),
    quantity INTEGER,
    requirementFulfillmentTime DATE NOT NULL,
    CONSTRAINT PKC_input_productRequirementDetails PRIMARY KEY (requirementId,stageId,productId,quantity,requirementFulfillmentTime),
    FOREIGN KEY (requirementId,stageId) REFERENCES input_productRequirements (requirementId,stageId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (productId) REFERENCES input_products (productId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE input_purchaseOrders
(
    purchaseOrderId VARCHAR(50),
    purchaserStageId VARCHAR(50),
    supplierStageId VARCHAR(50),
    expectedOrderFulfillmentTime DATE NOT NULL,
    purchaseDate DATE NOT NULL,
    requirementId VARCHAR(50) NOT NULL,
    totalAmount INTEGER NOT NULL,
    authorisedBy VARCHAR(50) NOT NULL,
    orderFulfillmentStatus VARCHAR(10) DEFAULT 'NOT DONE',
    CONSTRAINT PKC_input_purchaseOrders PRIMARY KEY (purchaseOrderId,purchaserStageId),
    CONSTRAINT CHK_orderFulfillmentStatus CHECK (orderFulfillmentStatus in ('DONE','NOT DONE')),
    FOREIGN KEY (supplierStageId) REFERENCES input_stageDetails (stageId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (requirementId,purchaserStageId) REFERENCES input_productRequirements (requirementId,stageId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (authorisedBy,purchaserStageId) REFERENCES input_employees (employeeId,stageId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE input_purchaseOrderDetails
(
    purchaseOrderId VARCHAR(50),
    purchaserStageId VARCHAR(50),
    supplierStageId VARCHAR(50),
    productId VARCHAR(50),
    quantity INTEGER NOT NULL,
    expectedOrderFulfillmentTime DATE,
    pricePerUnit INTEGER,
    orderFulfillmentStatus VARCHAR(10) DEFAULT 'NOT DONE',
    CONSTRAINT PKC_input_purchaseOrderDetails PRIMARY KEY (purchaseOrderId,purchaserStageId,productId,quantity,expectedOrderFulfillmentTime),
    CONSTRAINT CHK_orderFulfillmentStatus CHECK (orderFulfillmentStatus in ('DONE','NOT DONE')),
    FOREIGN KEY (purchaseOrderId,purchaserStageId) REFERENCES input_purchaseOrders (purchaseOrderId,purchaserStageId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (supplierStageId) REFERENCES input_stageDetails (stageId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (productId,pricePerUnit) REFERENCES input_products (productId,pricePerUnit)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE aux_incompletePurchaseOrderDetails  /*producer -consumer*/
(
    purchaseOrderId VARCHAR(50),
    purchaserStageId VARCHAR(50),
    supplierStageId VARCHAR(50),
    productId VARCHAR(50),
    remainingQuantity INTEGER NOT NULL,
    CONSTRAINT PKC_aux_incompleteOrderDetails PRIMARY KEY (purchaseOrderId,purchaserStageId,supplierStageId,productId),
    FOREIGN KEY (purchaseOrderId,purchaserStageId) REFERENCES input_purchaseOrders (purchaseOrderId,purchaserStageId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (supplierStageId) REFERENCES input_stageDetails (stageId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (productId) REFERENCES input_products (productId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE input_supplyOrders
(
    supplyOrderId VARCHAR(50),
    supplierStageId VARCHAR(50),
    purchaserStageId VARCHAR(50),
    expectedOrderFulfillmentTime DATE NOT NULL,
    saleDate DATE NOT NULL,
    totalAmount INTEGER NOT NULL,
    authorisedBy VARCHAR(50) NOT NULL,
    orderFulfillmentStatus VARCHAR(10) DEFAULT 'NOT DONE',
    CONSTRAINT PKC_input_supplyOrders PRIMARY KEY (supplyOrderId,supplierStageId,purchaserStageId),
    CONSTRAINT CHK_orderFulfillmentStatus CHECK (orderFulfillmentStatus in ('DONE','NOT DONE')),
    FOREIGN KEY (supplierStageId) REFERENCES input_stageDetails (stageId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (purchaserStageId) REFERENCES input_stageDetails (stageId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (authorisedBy,supplierStageId) REFERENCES input_employees (employeeId,stageId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE input_supplyOrderDetails
(
    supplyOrderId VARCHAR(50),
    supplierStageId VARCHAR(50),
    purchaserStageId VARCHAR(50),
    productId VARCHAR(50),
    quantity INTEGER,
    expectedOrderFulfillmentTime DATE NOT NULL,
    pricePerUnit INTEGER NOT NULL,
    orderFulfillmentStatus VARCHAR(10) DEFAULT 'NOT DONE',
    CONSTRAINT PKC_input_supplyOrders PRIMARY KEY (supplyOrderId,supplierStageId,purchaserStageId),
    CONSTRAINT CHK_orderFulfillmentStatus CHECK (orderFulfillmentStatus in ('DONE','NOT DONE')),
    FOREIGN KEY (supplierStageId) REFERENCES input_stageDetails (stageId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (purchaserStageId) REFERENCES input_stageDetails (stageId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (authorisedBy,supplierStageId) REFERENCES input_employees (employeeId,stageId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);



CREATE TABLE input_storageDetails
(
 ` storePlaceId VARCHAR(50) PRIMARY KEY,
  storePath TEXT NOT NULL
);

CREATE TABLE aux_stageInventory
(
    productId VARCHAR(50),
    stageId VARCHAR(50),
    quantity INTEGER NOT NULL,
    manufactureDate DATE NOT NULL,
    expiryDate DATE NOT NULL,
    price INTEGER NOT NULL,
    storePlaceId VARCHAR(50) NOT NULL,
    productArrivalTime DATE NOT NULL,
    manufacturingCode VARCHAR(250) NOT NULL,
    purchaseOrderId VARCHAR(50) NOT NULL,
    isProduced VARCHAR(4) NOT NULL DEFAULT 'Yes',
    CONSTRAINT PKC_aux_stageInventory PRIMARY KEY (productId,stageId,manufacturingCode,purchaseOrderId,storePlaceId),
    CONSTRAINT CHK_isproduced CHECK (isProduced in ('Yes','No')),
    FOREIGN KEY (productId) REFERENCES input_products (productId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (stageId) REFERENCES input_stageDetails (stageId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (storePlaceId) REFERENCES input_storageDetails (storePlaceId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (manufacturingCode) REFERENCES input_manufacturingDetails (manufacturingCode)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (purchaseOrderId) REFERENCES input_purchaseOrderDetails (purchaseOrderId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

/*still to complete
CREATE TABLE aux_productDispatchmentLog
(
    dispatchmentStageId VARCHAR(50),
    destinationStageId VARCHAR(50),
    dispatchmentStagepurchaseOrderId VARCHAR(50),
    productId VARCHAR(50),
    quantity INTEGER,
    manufactureDate DATE NOT NULL,
    expiryDate DATE NOT NULL,
    price INTEGER NOT NULL,
    storePlaceId VARCHAR(50) NOT NULL,
    dispatchmentStageArrivalTime DATE NOT NULL,
    dispatchTime DATE NOT NULL,
    manufacturingCode VARCHAR(250),
    CONSTRAINT PKC_aux_productDispatchmentDetails PRIMARY KEY (orderId,purchaseOrderId),
    FOREIGN KEY (orderId)
);*/
