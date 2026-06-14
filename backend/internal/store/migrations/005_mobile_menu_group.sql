INSERT INTO admin_menus(id, name, path, parent_id, type, permission) VALUES
  (15, '移动端管理', '/mobile', 0, 'menu', ''),
  (16, 'App用户', '/mobile/app-user', 15, 'menu', ''),
  (17, 'app-user:create', '', 16, 'button', 'app-user:create'),
  (18, 'app-user:edit', '', 16, 'button', 'app-user:edit'),
  (19, 'app-user:delete', '', 16, 'button', 'app-user:delete')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  path = EXCLUDED.path,
  parent_id = EXCLUDED.parent_id,
  type = EXCLUDED.type,
  permission = EXCLUDED.permission;

UPDATE admin_roles
SET menu_ids = '[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19]'::jsonb
WHERE role_key = 'super_admin';

SELECT setval(pg_get_serial_sequence('admin_menus', 'id'), COALESCE((SELECT MAX(id) FROM admin_menus), 1));
