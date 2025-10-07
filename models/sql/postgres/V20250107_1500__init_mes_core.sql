-- V20250107_1500__init_mes_core.sql
-- 初始化MES核心数据库结构
-- 作者: 开发团队
-- 日期: 2025-01-07
-- 描述: 创建MES系统核心表结构

-- 创建Schema
CREATE SCHEMA IF NOT EXISTS mes_core;

-- 设置搜索路径
SET search_path TO mes_core;

-- 启用UUID扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 创建工厂表
CREATE TABLE IF NOT EXISTS plants (
    plant_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    code varchar(32) NOT NULL,
    name varchar(128) NOT NULL,
    timezone varchar(64) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uk_plants_code UNIQUE (code)
);

-- 创建工作中心表
CREATE TABLE IF NOT EXISTS work_centers (
    work_center_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    plant_id uuid NOT NULL REFERENCES plants(plant_id),
    code varchar(32) NOT NULL,
    name varchar(128) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uk_work_centers_plant_code UNIQUE (plant_id, code)
);

-- 创建工位表
CREATE TABLE IF NOT EXISTS workstations (
    workstation_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    work_center_id uuid NOT NULL REFERENCES work_centers(work_center_id),
    code varchar(32) NOT NULL,
    name varchar(128) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uk_workstations_work_center_code UNIQUE (work_center_id, code)
);

-- 创建设备表
CREATE TABLE IF NOT EXISTS equipment (
    equipment_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    workstation_id uuid NOT NULL REFERENCES workstations(workstation_id),
    code varchar(32) NOT NULL,
    name varchar(128) NOT NULL,
    type varchar(64),
    serial_no varchar(64),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uk_equipment_workstation_code UNIQUE (workstation_id, code)
);

-- 创建传感器表
CREATE TABLE IF NOT EXISTS sensors (
    sensor_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    equipment_id uuid NOT NULL REFERENCES equipment(equipment_id),
    code varchar(32) NOT NULL,
    name varchar(128) NOT NULL,
    unit varchar(16),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uk_sensors_equipment_code UNIQUE (equipment_id, code)
);

-- 创建计量单位表
CREATE TABLE IF NOT EXISTS uoms (
    uom_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    code varchar(16) NOT NULL,
    name varchar(64) NOT NULL,
    base_code varchar(16) NOT NULL,
    factor_to_base decimal(18,6) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uk_uoms_code UNIQUE (code)
);

-- 创建物料表
CREATE TABLE IF NOT EXISTS materials (
    material_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    code varchar(64) NOT NULL,
    name varchar(256) NOT NULL,
    base_uom_id uuid NOT NULL REFERENCES uoms(uom_id),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uk_materials_code UNIQUE (code)
);

-- 创建库位表
CREATE TABLE IF NOT EXISTS locations (
    location_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    plant_id uuid NOT NULL REFERENCES plants(plant_id),
    code varchar(64) NOT NULL,
    name varchar(256) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uk_locations_plant_code UNIQUE (plant_id, code)
);

-- 创建批次表
CREATE TABLE IF NOT EXISTS lots (
    lot_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_id uuid NOT NULL REFERENCES materials(material_id),
    code varchar(64) NOT NULL,
    mfg_date date,
    expiry_date date,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uk_lots_material_code UNIQUE (material_id, code)
);

-- 创建库存表
CREATE TABLE IF NOT EXISTS inventory (
    inventory_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_id uuid NOT NULL REFERENCES materials(material_id),
    location_id uuid NOT NULL REFERENCES locations(location_id),
    lot_id uuid REFERENCES lots(lot_id),
    qty_on_hand decimal(18,6),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uk_inventory_material_location_lot UNIQUE (material_id, location_id, lot_id)
);

-- 创建员工表
CREATE TABLE IF NOT EXISTS employees (
    employee_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    code varchar(32) NOT NULL,
    name varchar(128) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uk_employees_code UNIQUE (code)
);

-- 创建技能表
CREATE TABLE IF NOT EXISTS skills (
    skill_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    code varchar(32) NOT NULL,
    name varchar(128) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uk_skills_code UNIQUE (code)
);

-- 创建员工技能关联表
CREATE TABLE IF NOT EXISTS employee_skills (
    employee_skill_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id uuid NOT NULL REFERENCES employees(employee_id),
    skill_id uuid NOT NULL REFERENCES skills(skill_id),
    valid_from timestamptz,
    valid_to timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 创建班次表
CREATE TABLE IF NOT EXISTS shifts (
    shift_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    plant_id uuid NOT NULL REFERENCES plants(plant_id),
    code varchar(32) NOT NULL,
    name varchar(128) NOT NULL,
    start_time time NOT NULL,
    end_time time NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 创建日历表
CREATE TABLE IF NOT EXISTS calendars (
    calendar_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    plant_id uuid NOT NULL REFERENCES plants(plant_id),
    date date NOT NULL,
    is_working_day bool NOT NULL,
    remarks varchar(256),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uk_calendars_plant_date UNIQUE (plant_id, date)
);

-- 创建质量代码表
CREATE TABLE IF NOT EXISTS quality_codes (
    quality_code_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    code varchar(32) NOT NULL,
    name varchar(128) NOT NULL,
    category varchar(64),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uk_quality_codes_code UNIQUE (code)
);

-- 创建停机代码表
CREATE TABLE IF NOT EXISTS downtime_codes (
    downtime_code_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    code varchar(32) NOT NULL,
    name varchar(128) NOT NULL,
    category varchar(64),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uk_downtime_codes_code UNIQUE (code)
);
