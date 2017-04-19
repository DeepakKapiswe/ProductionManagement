
DROP DATABASE IF EXISTS productdb;
CREATE DATABASE productdb;
USE productdb;


CREATE TABLE input_static_products
(
    productId VARCHAR(50),
    productName VARCHAR(255) NOT NULL,
    pricePerUnit INTEGER NOT NULL,
    entryTimeStamp DATE NOT NULL,
    CONSTRAINT PKC_input_static_products PRIMARY KEY (productId)
);

CREATE TABLE input_static_stages
(
    stageId VARCHAR(50),
    stageName VARCHAR(250),
    entryTimeStamp DATE NOT NULL,
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
    entryTimeStamp DATE NOT NULL,
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
    entryTimeStamp DATE NOT NULL,
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
    entryTimeStamp DATE NOT NULL,
    CONSTRAINT PKC_input_static_produtionUnitTypes PRIMARY KEY (productionUnitTypeId),
    FOREIGN KEY (locationType) REFERENCES aux_locationTypeDomain (locationType)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE input_static_produtionUnitTypeStages
(
    productionUnitTypeId VARCHAR(50),
    stageId VARCHAR(50)
    entryTimeStamp DATE NOT NULL,
    CONSTRAINT PKC_input_static_produtionUnitTypeStages PRIMARY KEY (productionUnitTypeId,stageId),
    FOREIGN KEY (stageId) REFERENCES input_static_stages (stageId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (productionUnitTypeId) REFERENCES input_static_produtionUnitTypes (productionUnitTypeId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE input_static_produtionUnits
(
    productionUnitId VARCHAR(50),
    productionUnitTypeId VARCHAR(50),
    entryTimeStamp DATE NOT NULL,
    CONSTRAINT PKC_input_static_produtionUnits PRIMARY KEY (productionUnitId),
    FOREIGN KEY (productionUnitTypeId) REFERENCES input_static_produtionUnitTypes (productionUnitTypeId)
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

CREATE TABLE input_static_produtionUnitCapacities
(
    productionUnitId VARCHAR(50),
    productId VARCHAR (50),
    maxStorageQuantity INTEGER NOT NULL,
    maxHoldingDuration INTEGER NOT NULL,
    entryTimeStamp DATE NOT NULL,
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
    entryTimeStamp DATE NOT NULL,
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
    manufacturedProductId VARCHAR(50),
    expiryTimeUnits INTEGER NOT NULL,
    entryTimeStamp DATE NOT NULL,
    CONSTRAINT PKC_input_static_productExpiries PRIMARY KEY (productionUnitId,stageId,productId),
    FOREIGN KEY (productionUnitId,stageId) REFERENCES aux_productionUnitStages (productionUnitId,stageId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (productionUnitId,manufacturedProductId) REFERENCES aux_productionUnitProducts (productionUnitId,productId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE input_static_transportTimeDetails        /*static-dynamic inputs*/
(
    sourceProductionUnitId VARCHAR(50),
    destinationProductionUnitId VARCHAR(50),
    productId VARCHAR(50),
    quantity INTEGER NOT NULL,
    timeUnitsRequired INTEGER NOT NULL,
    entryTimeStamp DATE NOT NULL,
    CONSTRAINT PKC_input_static_transportationDetails PRIMARY KEY (sourceProductionUnitId,destinationProductionUnitId,productId,quantity),
    FOREIGN KEY (sourceProductionUnitId,productId) REFERENCES aux_productionUnitProducts (productionUnitId,productId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (destinationProductionUnitId,productId) REFERENCES aux_productionUnitProducts (productionUnitId,productId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

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
    productionOrderDate DATE NOT NULL,
    expectedTotalProductionTime DATE NOT NULL,
    authorisedBy VARCHAR(50) NOT NULL,
    description TEXT,
    CONSTRAINT PKC_input_dynamic_productionOrders PRIMARY KEY (productionOrderId,productionUnitId),
    FOREIGN KEY (productionUnitId) REFERENCES input_static_produtionUnits (productionUnitId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (authorisedBy) REFERENCES input_static_employees (employeeId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

/* Through trigger extract productId and quantity from input_productionOrders then refer it in input_productionOrderDetails */

CREATE TABLE input_dynamic_productionOrderDetails
(
    productionOrderId VARCHAR(50),
    productionUnitId VARCHAR(50),
    productId VARCHAR(50),
    quantity INTEGER NOT NULL,
    expectedProductionTime DATE NOT NULL,
    CONSTRAINT PKC_input_dynamic_productionOrderDetails PRIMARY KEY (productionOrderId,productionUnitId,productId,quantity,expectedProductionTime),
    ON DELETE RESTRICT ON UPDATE CASCADE
    FOREIGN KEY (productionOrderId,productionUnitId) REFERENCES input_dynamic_productionOrders (productionOrderId,productionUnitId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (productionUnitId,productId) REFERENCES aux_productionUnitProducts (productionUnitId,productId)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE output_incompleteProductionOrderDetails /*output*/
(
    productionOrderId VARCHAR(50),
    productionUnitId VARCHAR(50),
    productId VARCHAR(50),
    remainingQuantity INTEGER NOT NULL,
    expectedProductionTime DATE NOT NULL,
    CONSTRAINT PKC_output_incompleteProductionOrderDetails PRIMARY KEY (productionOrderId,productionUnitId,productId,remainingQuantity,expectedProductionTime),
    FOREIGN KEY (productionOrderId,productionUnitId) REFERENCES input_dynamic_productionOrders (productionOrderId,productionUnitId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (productionUnitId,productId) REFERENCES aux_productionUnitProducts (productionUnitId,productId)
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
    CONSTRAINT PKC_input_dynamic_manufacturingDetails PRIMARY KEY (manufacturingCode),
    FOREIGN KEY (productionOrderId,productionUnitId) REFERENCES input_dynamic_productionOrders (productionOrderId,productionUnitId)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (batchNo) REFERENCES aux_batchNumberDomain (batchNo)
    ON DELETE RESTRICT ON UPDATE CASCADE
);


