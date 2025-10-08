#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
拆分btc_core_schema.sql为多个小文件
每个文件控制在200行以内
"""

import os
import re

def ensure_dir(directory):
    """确保目录存在"""
    if not os.path.exists(directory):
        os.makedirs(directory)

def count_lines(text):
    """统计文本行数"""
    return len(text.strip().split('\n'))

def write_file(filepath, content, header):
    """写入文件"""
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(header)
        f.write(content)
    lines = count_lines(header + content)
    print(f"[OK] Created {os.path.basename(filepath)} ({lines} lines)")

def split_schema():
    """拆分schema文件"""
    
    input_file = 'mes-backend/database/schemas/btc_core_schema.sql'
    output_dir = 'mes-backend/database/schemas/btc_core_split'
    
    ensure_dir(output_dir)
    
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    header = """-- ==============================================
-- BTC核心数据库 - {}
-- ==============================================

USE btc_core;

"""
    
    # 定义所有表的起止标记
    table_defs = [
        ('01_tenant_dept.sql', '租户和部门表', 
         'CREATE TABLE tenant', ') COMMENT \'部门表\';'),
        
        ('02_user.sql', '用户表',
         'CREATE TABLE sys_user', ') COMMENT \'系统用户表\';'),
        
        ('03_role_permission.sql', '角色和权限表',
         'CREATE TABLE sys_role', ') COMMENT \'系统权限表\';'),
        
        ('04_menu.sql', '菜单表',
         'CREATE TABLE sys_menu', ') COMMENT \'菜单权限关联表\';'),
        
        ('05_module_plugin.sql', '模块和插件表',
         'CREATE TABLE sys_module', ') COMMENT \'用户模块关联表\';'),
        
        ('06_menu_permission.sql', '菜单权限关联表',
         'CREATE TABLE sys_menu_permission', ') COMMENT \'菜单权限关联表\';'),
        
        ('07_position.sql', '职位表',
         'CREATE TABLE sys_position', ') COMMENT \'职位角色映射表\';'),
        
        ('08_user_role.sql', '用户角色和角色权限关联表',
         'CREATE TABLE sys_user_role', ') COMMENT \'角色权限关联表\';'),
        
        ('09_workflow.sql', '工作流表',
         'CREATE TABLE workflow_definition', ') COMMENT \'流程历史表\';'),
        
        ('10_trace_maps.sql', '追溯映射表',
         'CREATE TABLE map_sn', ') COMMENT \'批次物料映射表\';'),
        
        ('11_trace_events.sql', '追溯事件表',
         'CREATE TABLE trace_event', ') COMMENT \'追溯链路快照表\';'),
        
        ('12_test_measure.sql', '测试和测量表',
         'CREATE TABLE test_record', ') COMMENT \'测量记录表\';'),
    ]
    
    # 提取并保存表定义
    for filename, desc, start_marker, end_marker in table_defs:
        start_idx = content.find(start_marker)
        end_idx = content.find(end_marker, start_idx) + len(end_marker)
        
        if start_idx != -1 and end_idx != -1:
            table_content = content[start_idx:end_idx]
            write_file(
                os.path.join(output_dir, filename),
                table_content + '\n',
                header.format(desc)
            )
    
    # 数据插入部分
    data_sections = [
        ('data_20_tenant_dept.sql', '租户和部门数据',
         '-- 插入三个租户数据', "('DEPT_SUPPLIER_RAW', 'TENANT_SUPPLIER', 'RAW_MATERIAL', '原材料供应商', 'DEPARTMENT', 2, 'SYSTEM');"),
        
        ('data_24_roles.sql', '角色数据',
         '-- 插入基于业务行为的RBAC角色数据', "('ROLE_SUPPLIER_MOLD_UPDATE', 'TENANT_SUPPLIER', NULL, 'SUPPLIER_MOLD_UPDATE', '模具状态更新', 'SUPPLIER', 1, 'SELF', FALSE, FALSE, 'SYSTEM');"),
        
        ('data_25_positions.sql', '职位数据',
         '-- 插入职位数据（基于user_profile真实职位）', "('POS_SUPPLIER_MATERIAL', 'TENANT_SUPPLIER', 'SUPPLIER_MATERIAL', '原材料供应商', 'DEPT_SUPPLIER_RAW', 4, 'SYSTEM');"),
    ]
    
    for filename, desc, start_marker, end_marker in data_sections:
        start_idx = content.find(start_marker)
        if start_idx == -1:
            continue
        end_idx = content.find(end_marker, start_idx) + len(end_marker)
        
        if end_idx > start_idx:
            data_content = content[start_idx:end_idx]
            write_file(
                os.path.join(output_dir, filename),
                data_content + '\n',
                header.format(desc)
            )
    
    # 处理用户数据 - 分成3个文件
    user_data_start = content.find('-- 插入基于user_profile的真实用户数据')
    user_data_end = content.find("('USER_110'", user_data_start)
    
    if user_data_start != -1 and user_data_end != -1:
        user_section = content[user_data_start:user_data_end + 200]
        
        # UK + INERT用户
        inert_end = user_section.find("-- IT部门 (3人)") + 500
        write_file(
            os.path.join(output_dir, 'data_21_users_inert.sql'),
            user_section[:inert_end] + '\n',
            header.format('INERT内网用户数据')
        )
        
    # 职位-角色映射 - 分成2个文件
    mapping_start = content.find('-- 插入职位-角色映射数据')
    mapping_end = content.find("('POS_SUPPLIER_MATERIAL', 'ROLE_SUPPLIER_DELIVERY_MANAGE'", mapping_start) + 100
    
    if mapping_start != -1 and mapping_end > mapping_start:
        mapping_content = content[mapping_start:mapping_end]
        mid_point = len(mapping_content) // 2
        
        # 找最近的完整INSERT语句
        mid_insert = mapping_content.rfind('\n(', 0, mid_point) + 1
        
        write_file(
            os.path.join(output_dir, 'data_26_position_role_map_01.sql'),
            mapping_content[:mid_insert],
            header.format('职位-角色映射数据（第1部分）')
        )
        
        write_file(
            os.path.join(output_dir, 'data_27_position_role_map_02.sql'),
            'INSERT INTO sys_position_role (position_id, role_id, is_default, created_by) VALUES\n' + 
            mapping_content[mid_insert:],
            header.format('职位-角色映射数据（第2部分）')
        )
    
    print(f"\n[OK] Split completed! Generated {len(os.listdir(output_dir))} files")
    print(f"Output directory: {output_dir}")

if __name__ == '__main__':
    split_schema()

