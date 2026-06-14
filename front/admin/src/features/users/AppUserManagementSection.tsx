import type { FormEvent } from 'react'

import type { AppUser, AppUserForm } from '../../adminTypes'
import { FormActions, PanelTitle, RowActions } from '../../components/shared'

const emptyAppUser: AppUserForm = {
  username: '',
  nickname: '',
  password: '',
}

export function AppUserManagementSection({
  users,
  userForm,
  saving,
  can,
  onUserFormChange,
  onSaveUser,
  onDeleteUser,
}: {
  users: AppUser[]
  userForm: AppUserForm
  saving: boolean
  can: (permission: string) => boolean
  onUserFormChange: (form: AppUserForm) => void
  onSaveUser: (event: FormEvent) => void
  onDeleteUser: (id: number) => void
}) {
  return (
    <section className="content-grid">
      <section className="table-panel">
        <PanelTitle title="App用户列表" count={users.length} />
        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th>用户名</th>
                <th>昵称</th>
                <th>操作</th>
              </tr>
            </thead>
            <tbody>
              {users.map((user) => (
                <tr key={user.id}>
                  <td>{user.username}</td>
                  <td>{user.nickname || '-'}</td>
                  <td>
                    <RowActions
                      canEdit={can('app-user:edit')}
                      canDelete={can('app-user:delete')}
                      onEdit={() => onUserFormChange({ ...user, password: '' })}
                      onDelete={() => onDeleteUser(user.id)}
                    />
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>

      <form className="editor-panel" onSubmit={onSaveUser}>
        <PanelTitle title={userForm.id ? '编辑App用户' : '新增App用户'} />
        <label>
          用户名
          <input
            value={userForm.username}
            onChange={(event) =>
              onUserFormChange({ ...userForm, username: event.target.value })
            }
            placeholder="user"
          />
        </label>
        <label>
          昵称
          <input
            value={userForm.nickname}
            onChange={(event) =>
              onUserFormChange({ ...userForm, nickname: event.target.value })
            }
            placeholder="App用户"
          />
        </label>
        <label>
          密码
          <input
            type="password"
            value={userForm.password}
            onChange={(event) =>
              onUserFormChange({ ...userForm, password: event.target.value })
            }
            placeholder={userForm.id ? '留空不修改' : '请输入密码'}
          />
        </label>
        <FormActions
          busy={saving}
          editing={Boolean(userForm.id)}
          createPermission="app-user:create"
          editPermission="app-user:edit"
          can={can}
          onReset={() => onUserFormChange(emptyAppUser)}
        />
      </form>
    </section>
  )
}
