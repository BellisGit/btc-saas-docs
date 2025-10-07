-- V20250107_1601__add_foreign_keys.sql
-- 添加外键约束
-- 基于MES系统全局架构基础文档
-- 作者: MES开发团队
-- 日期: 2025-01-07

-- 使用MES核心数据库
USE mes_core;

-- ==============================================
-- 添加外键约束
-- ==============================================

-- 物料主数据表外键
ALTER TABLE item_master 
ADD CONSTRAINT fk_item_supplier 
FOREIGN KEY (supplier_id) REFERENCES supplier_master(supplier_id);

-- 模具主数据表外键
ALTER TABLE mold_master 
ADD CONSTRAINT fk_mold_supplier 
FOREIGN KEY (supplier_id) REFERENCES supplier_master(supplier_id);

ALTER TABLE mold_master 
ADD CONSTRAINT fk_mold_item 
FOREIGN KEY (item_id) REFERENCES item_master(item_id);

-- 采购订单表外键
ALTER TABLE purchase_order 
ADD CONSTRAINT fk_po_supplier 
FOREIGN KEY (supplier_id) REFERENCES supplier_master(supplier_id);

-- 采购订单明细表外键
ALTER TABLE purchase_order_item 
ADD CONSTRAINT fk_poi_po 
FOREIGN KEY (po_id) REFERENCES purchase_order(po_id);

ALTER TABLE purchase_order_item 
ADD CONSTRAINT fk_poi_item 
FOREIGN KEY (item_id) REFERENCES item_master(item_id);

-- 收货单表外键
ALTER TABLE goods_receipt_note 
ADD CONSTRAINT fk_grn_po 
FOREIGN KEY (po_id) REFERENCES purchase_order(po_id);

ALTER TABLE goods_receipt_note 
ADD CONSTRAINT fk_grn_supplier 
FOREIGN KEY (supplier_id) REFERENCES supplier_master(supplier_id);

-- 收货明细表外键
ALTER TABLE goods_receipt_item 
ADD CONSTRAINT fk_gri_grn 
FOREIGN KEY (grn_id) REFERENCES goods_receipt_note(grn_id);

ALTER TABLE goods_receipt_item 
ADD CONSTRAINT fk_gri_item 
FOREIGN KEY (item_id) REFERENCES item_master(item_id);

-- 生产工单表外键
ALTER TABLE work_order 
ADD CONSTRAINT fk_wo_item 
FOREIGN KEY (item_id) REFERENCES item_master(item_id);

-- 生产批次表外键
ALTER TABLE production_lot 
ADD CONSTRAINT fk_lot_wo 
FOREIGN KEY (wo_id) REFERENCES work_order(wo_id);

ALTER TABLE production_lot 
ADD CONSTRAINT fk_lot_item 
FOREIGN KEY (item_id) REFERENCES item_master(item_id);

-- 序列号表外键
ALTER TABLE serial_number 
ADD CONSTRAINT fk_sn_lot 
FOREIGN KEY (lot_id) REFERENCES production_lot(lot_id);

ALTER TABLE serial_number 
ADD CONSTRAINT fk_sn_item 
FOREIGN KEY (item_id) REFERENCES item_master(item_id);

ALTER TABLE serial_number 
ADD CONSTRAINT fk_sn_wo 
FOREIGN KEY (wo_id) REFERENCES work_order(wo_id);

-- 工艺路线表外键
ALTER TABLE routing 
ADD CONSTRAINT fk_routing_item 
FOREIGN KEY (item_id) REFERENCES item_master(item_id);

-- 工序定义表外键
ALTER TABLE operation 
ADD CONSTRAINT fk_operation_routing 
FOREIGN KEY (routing_id) REFERENCES routing(routing_id);

-- 检验明细表外键
ALTER TABLE inspection_item 
ADD CONSTRAINT fk_insp_item_insp 
FOREIGN KEY (insp_id) REFERENCES inspection(insp_id);

-- 批次用料映射表外键
ALTER TABLE map_lot_material 
ADD CONSTRAINT fk_mlm_lot 
FOREIGN KEY (lot_id) REFERENCES production_lot(lot_id);

ALTER TABLE map_lot_material 
ADD CONSTRAINT fk_mlm_item 
FOREIGN KEY (item_id) REFERENCES item_master(item_id);

ALTER TABLE map_lot_material 
ADD CONSTRAINT fk_mlm_supplier 
FOREIGN KEY (supplier_id) REFERENCES supplier_master(supplier_id);

ALTER TABLE map_lot_material 
ADD CONSTRAINT fk_mlm_mold 
FOREIGN KEY (mold_id) REFERENCES mold_master(mold_id);

-- 序列号映射表外键
ALTER TABLE map_sn 
ADD CONSTRAINT fk_map_sn_lot 
FOREIGN KEY (lot_id) REFERENCES production_lot(lot_id);

ALTER TABLE map_sn 
ADD CONSTRAINT fk_map_sn_wo 
FOREIGN KEY (wo_id) REFERENCES work_order(wo_id);
