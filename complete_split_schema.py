#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
完整拆分btc_core_schema.sql
将所有供应商用户数据也补充position_id字段并拆分
"""

import os
import re

def process_supplier_users():
    """处理供应商用户数据，补充position_id"""
    input_file = 'mes-backend/database/schemas/btc_core_schema.sql'
    
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 使用正则表达式批量替换供应商用户数据，添加position_id
    # 匹配模式: ('USER_XX', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', '用户名',
    # 替换为: ('USER_XX', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'POS_SUPPLIER_MATERIAL', '用户名',
    pattern = r"(\('USER_\d+', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', )('POS_SUPPLIER_MATERIAL', )?(['\"])"
    replacement = r"\1'POS_SUPPLIER_MATERIAL', \3"
    
    updated_content = re.sub(pattern, replacement, content)
    
    # 写回文件
    with open(input_file, 'w', encoding='utf-8') as f:
        f.write(updated_content)
    
    print("[OK] Updated supplier user data with position_id")
    return updated_content

def split_supplier_users(content):
    """将供应商用户数据拆分为两个文件"""
    output_dir = 'mes-backend/database/schemas/btc_core_split'
    
    # 查找供应商用户数据段
    supplier_start = content.find('-- === 供应商用户 (TENANT_SUPPLIER) - 52人 ===')
    supplier_end = content.find("('USER_110'", supplier_start) + 200
    
    if supplier_start == -1:
        return
    
    supplier_section = content[supplier_start:supplier_end]
    lines = supplier_section.split('\n')
    
    # 分成两部分
    mid_point = len(lines) // 2
    
    header = """-- ==============================================
-- BTC核心数据库 - {}
-- ==============================================

USE btc_core;

"""
    
    # 第1部分: USER_59 ~ USER_84
    part1 = []
    part2 = []
    found_user_85 = False
    
    for line in lines:
        if 'USER_85' in line:
            found_user_85 = True
        
        if not found_user_85:
            part1.append(line)
        else:
            part2.append(line)
    
    # 写入文件
    with open(os.path.join(output_dir, 'data_22_users_supplier_01.sql'), 'w', encoding='utf-8') as f:
        f.write(header.format('供应商用户数据（USER_59-84）'))
        f.write('\n'.join(part1))
    
    # 为第2部分添加INSERT语句
    insert_stmt = "INSERT INTO sys_user (user_id, tenant_id, dept_id, position_id, username, password_hash, real_name, email, user_type, status, created_by)\nVALUES\n"
    
    with open(os.path.join(output_dir, 'data_23_users_supplier_02.sql'), 'w', encoding='utf-8') as f:
        f.write(header.format('供应商用户数据（USER_85-110）'))
        f.write(insert_stmt)
        f.write('\n'.join(part2))
    
    print(f"[OK] Created data_22_users_supplier_01.sql ({len(part1)} lines)")
    print(f"[OK] Created data_23_users_supplier_02.sql ({len(part2)} lines)")

def create_remaining_data_files():
    """创建其余的数据文件"""
    input_file = 'mes-backend/database/schemas/btc_core_schema.sql'
    output_dir = 'mes-backend/database/schemas/btc_core_split'
    
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    header = """-- ==============================================
-- BTC核心数据库 - {}
-- ==============================================

USE btc_core;

"""
    
    # 模块和插件数据
    modules_start = content.find('-- 插入模块数据')
    modules_end = content.find('-- 插入菜单数据')
    
    if modules_start != -1 and modules_end != -1:
        modules_data = content[modules_start:modules_end]
        with open(os.path.join(output_dir, 'data_28_modules_plugins.sql'), 'w', encoding='utf-8') as f:
            f.write(header.format('模块和插件数据'))
            f.write(modules_data)
        print("[OK] Created data_28_modules_plugins.sql")
    
    # 菜单数据
    menu_start = content.find('-- 插入菜单数据')
    menu_end = content.find('-- 插入用户-模块关联数据')
    
    if menu_start != -1 and menu_end != -1:
        menu_data = content[menu_start:menu_end]
        with open(os.path.join(output_dir, 'data_29_menus.sql'), 'w', encoding='utf-8') as f:
            f.write(header.format('菜单数据'))
            f.write(menu_data)
        print("[OK] Created data_29_menus.sql")
    
    # 用户-模块关联数据
    user_module_start = content.find('-- 插入用户-模块关联数据')
    user_module_end = content.find('-- 插入基于流程树的权限数据')
    
    if user_module_start != -1 and user_module_end != -1:
        user_module_data = content[user_module_start:user_module_end]
        with open(os.path.join(output_dir, 'data_30_user_modules.sql'), 'w', encoding='utf-8') as f:
            f.write(header.format('用户-模块关联数据'))
            f.write(user_module_data)
        print("[OK] Created data_30_user_modules.sql")
    
    # 权限数据
    perm_start = content.find('-- 插入基于流程树的权限数据')
    perm_end = content.find('-- 插入角色权限关联数据')
    
    if perm_start != -1 and perm_end != -1:
        perm_data = content[perm_start:perm_end]
        # 如果权限数据太长，也进行拆分
        if len(perm_data.split('\n')) > 200:
            lines = perm_data.split('\n')
            mid = len(lines) // 2
            
            with open(os.path.join(output_dir, 'data_31_permissions_01.sql'), 'w', encoding='utf-8') as f:
                f.write(header.format('权限数据（第1部分）'))
                f.write('\n'.join(lines[:mid]))
            
            with open(os.path.join(output_dir, 'data_31_permissions_02.sql'), 'w', encoding='utf-8') as f:
                f.write(header.format('权限数据（第2部分）'))
                # 添加INSERT语句
                f.write("INSERT INTO sys_permission (permission_id, tenant_id, permission_code, permission_name, permission_type, resource_type, resource_id, action, created_by) VALUES\n")
                f.write('\n'.join(lines[mid:]))
            print("[OK] Created data_31_permissions_01.sql and data_31_permissions_02.sql")
        else:
            with open(os.path.join(output_dir, 'data_31_permissions.sql'), 'w', encoding='utf-8') as f:
                f.write(header.format('权限数据'))
                f.write(perm_data)
            print("[OK] Created data_31_permissions.sql")
    
    # 角色权限关联数据
    role_perm_start = content.find('-- 插入角色权限关联数据')
    
    if role_perm_start != -1:
        role_perm_data = content[role_perm_start:]
        # 截取到文件末尾或下一个大section
        if len(role_perm_data) > 5000:
            role_perm_data = role_perm_data[:5000]
        
        # 如果数据太长，拆分
        if len(role_perm_data.split('\n')) > 200:
            lines = role_perm_data.split('\n')
            mid = len(lines) // 2
            
            with open(os.path.join(output_dir, 'data_32_role_permissions_01.sql'), 'w', encoding='utf-8') as f:
                f.write(header.format('角色权限关联（第1部分）'))
                f.write('\n'.join(lines[:mid]))
            
            with open(os.path.join(output_dir, 'data_32_role_permissions_02.sql'), 'w', encoding='utf-8') as f:
                f.write(header.format('角色权限关联（第2部分）'))
                f.write("INSERT INTO sys_role_permission (role_id, permission_id, created_by) VALUES\n")
                f.write('\n'.join(lines[mid:]))
            print("[OK] Created data_32_role_permissions_01.sql and data_32_role_permissions_02.sql")
        else:
            with open(os.path.join(output_dir, 'data_32_role_permissions.sql'), 'w', encoding='utf-8') as f:
                f.write(header.format('角色权限关联'))
                f.write(role_perm_data)
            print("[OK] Created data_32_role_permissions.sql")

def main():
    print("Starting complete schema split process...")
    print("=" * 60)
    
    # Step 1: 处理供应商用户数据
    print("\nStep 1: Processing supplier user data...")
    updated_content = process_supplier_users()
    
    # Step 2: 拆分供应商用户数据
    print("\nStep 2: Splitting supplier user data...")
    split_supplier_users(updated_content)
    
    # Step 3: 创建其余数据文件
    print("\nStep 3: Creating remaining data files...")
    create_remaining_data_files()
    
    print("\n" + "=" * 60)
    print("[DONE] Complete schema split finished!")
    print("Check directory: mes-backend/database/schemas/btc_core_split/")

if __name__ == '__main__':
    main()

