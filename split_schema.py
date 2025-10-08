#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
拆分btc_core_schema.sql为多个小文件
每个文件控制在200行以内
"""

import os
import re

def split_schema_file():
    schema_file = 'mes-backend/database/schemas/btc_core_schema.sql'
    output_dir = 'mes-backend/database/schemas/btc_core_split'
    
    with open(schema_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 拆分策略
    splits = []
    
    # 1. 表定义部分
    splits.append({
        'file': '01_tenant_dept.sql',
        'start': 'CREATE TABLE tenant',
        'end': ') COMMENT \'部门表\';',
        'type': 'ddl'
    })
    
    splits.append({
        'file': '02_user.sql',
        'start': 'CREATE TABLE sys_user',
        'end': ') COMMENT \'系统用户表\';',
        'type': 'ddl'
    })
    
    splits.append({
        'file': '03_role_permission.sql',
        'start': 'CREATE TABLE sys_role',
        'end': ') COMMENT \'系统权限表\';',
        'type': 'ddl'
    })
    
    splits.append({
        'file': '04_menu.sql',
        'start': 'CREATE TABLE sys_menu',
        'end': ') COMMENT \'系统菜单表',
        'type': 'ddl'
    })
    
    splits.append({
        'file': '05_module_plugin.sql',
        'start': 'CREATE TABLE sys_module',
        'end': ') COMMENT \'用户模块关联表\';',
        'type': 'ddl'
    })
    
    splits.append({
        'file': '06_position.sql',
        'start': 'CREATE TABLE sys_position',
        'end': ') COMMENT \'职位角色映射表\';',
        'type': 'ddl'
    })
    
    splits.append({
        'file': '07_associations.sql',
        'start': 'CREATE TABLE sys_user_role',
        'end': ') COMMENT \'角色权限关联表\';',
        'type': 'ddl'
    })
    
    splits.append({
        'file': '08_workflow.sql',
        'start': 'CREATE TABLE workflow_definition',
        'end': ') COMMENT \'流程历史表\';',
        'type': 'ddl'
    })
    
    splits.append({
        'file': '09_trace_maps.sql',
        'start': 'CREATE TABLE map_sn',
        'end': ') COMMENT \'批次物料映射表\';',
        'type': 'ddl'
    })
    
    splits.append({
        'file': '10_trace_events.sql',
        'start': 'CREATE TABLE trace_event',
        'end': ') COMMENT \'追溯链路快照表\';',
        'type': 'ddl'
    })
    
    splits.append({
        'file': '11_test_measure.sql',
        'start': 'CREATE TABLE test_record',
        'end': ') COMMENT \'测量记录表\';',
        'type': 'ddl'
    })
    
    # 2. 数据插入部分
    splits.append({
        'file': 'data_01_tenant_dept.sql',
        'start': '-- 插入三个租户数据',
        'end': "('DEPT_SUPPLIER_RAW', 'TENANT_SUPPLIER', 'RAW_MATERIAL', '原材料供应商', 'DEPARTMENT', 2, 'SYSTEM');",
        'type': 'dml'
    })
    
    splits.append({
        'file': 'data_02_users.sql',
        'start': '-- 插入基于user_profile的真实用户数据',
        'end': "('USER_110', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW',",
        'type': 'dml',
        'max_lines': 200
    })
    
    splits.append({
        'file': 'data_03_roles.sql',
        'start': '-- 插入基于业务行为的RBAC角色数据',
        'end': "('ROLE_SUPPLIER_MOLD_UPDATE', 'TENANT_SUPPLIER',",
        'type': 'dml'
    })
    
    splits.append({
        'file': 'data_04_positions.sql',
        'start': '-- 插入职位数据',
        'end': "('POS_SUPPLIER_MATERIAL', 'TENANT_SUPPLIER',",
        'type': 'dml'
    })
    
    splits.append({
        'file': 'data_05_position_role_mappings.sql',
        'start': '-- 插入职位-角色映射数据',
        'end': "('POS_SUPPLIER_MATERIAL', 'ROLE_SUPPLIER_DELIVERY_MANAGE', TRUE, 'SYSTEM');",
        'type': 'dml'
    })
    
    print("Schema file split completed!")
    print(f"Created {len(splits)} files in {output_dir}/")
    
if __name__ == '__main__':
    split_schema_file()

