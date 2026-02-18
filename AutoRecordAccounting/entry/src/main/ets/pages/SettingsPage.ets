import { router } from '@kit.ArkUI'
import { preferences } from '@kit.ArkData'
import { DEFAULT_SETTINGS, STORAGE_KEYS } from '../constants/AppConstants'

@Entry
@Component
struct SettingsPage {
  @State autoRecordEnabled: boolean = false
  @State floatWindowEnabled: boolean = true
  @State vibrationEnabled: boolean = true
  @State soundEnabled: boolean = false
  private preference: preferences.Preferences | null = null

  aboutToAppear() {
    this.loadSettings()
  }

  async loadSettings() {
    try {
      this.preference = preferences.getPreferencesSync(getContext(), { name: 'app_settings' })
      
      this.autoRecordEnabled = this.preference.getSync(STORAGE_KEYS.AUTO_RECORD_ENABLED, DEFAULT_SETTINGS.autoRecordEnabled) as boolean
      this.floatWindowEnabled = this.preference.getSync('float_window_enabled', DEFAULT_SETTINGS.floatWindowEnabled) as boolean
      this.vibrationEnabled = this.preference.getSync('vibration_enabled', DEFAULT_SETTINGS.vibrationEnabled) as boolean
      this.soundEnabled = this.preference.getSync('sound_enabled', DEFAULT_SETTINGS.soundEnabled) as boolean
    } catch (err) {
      console.error('加载设置失败:', err)
    }
  }

  async saveSettings() {
    if (!this.preference) return

    try {
      await this.preference.put(STORAGE_KEYS.AUTO_RECORD_ENABLED, this.autoRecordEnabled)
      await this.preference.put('float_window_enabled', this.floatWindowEnabled)
      await this.preference.put('vibration_enabled', this.vibrationEnabled)
      await this.preference.put('sound_enabled', this.soundEnabled)
      await this.preference.flush()
    } catch (err) {
      console.error('保存设置失败:', err)
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Button() {
          Text('←')
            .fontSize(24)
            .fontColor('#333')
        }
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          router.back()
        })

        Text('设置')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank()
          .width(44)
      }
      .width('100%')
      .padding(16)

      Scroll() {
        Column({ space: 16 }) {
          // 自动记账设置组
          SettingsGroup({ title: '自动记账' }) {
            ToggleSettingItem({
              icon: '🤖',
              title: '自动识别支付',
              subtitle: '开启后自动监听支付页面',
              isOn: this.autoRecordEnabled,
              onChange: (value) => {
                this.autoRecordEnabled = value
                this.saveSettings()
              }
            })

            ToggleSettingItem({
              icon: '🔔',
              title: '悬浮确认窗',
              subtitle: '支付后显示确认弹窗',
              isOn: this.floatWindowEnabled,
              onChange: (value) => {
                this.floatWindowEnabled = value
                this.saveSettings()
              }
            })
          }

          // 通知设置组
          SettingsGroup({ title: '通知' }) {
            ToggleSettingItem({
              icon: '📳',
              title: '震动提醒',
              subtitle: '记账成功时震动',
              isOn: this.vibrationEnabled,
              onChange: (value) => {
                this.vibrationEnabled = value
                this.saveSettings()
              }
            })

            ToggleSettingItem({
              icon: '🔊',
              title: '声音提醒',
              subtitle: '记账成功时播放提示音',
              isOn: this.soundEnabled,
              onChange: (value) => {
                this.soundEnabled = value
                this.saveSettings()
              }
            })
          }

          // 数据管理组
          SettingsGroup({ title: '数据管理' }) {
            NavigationSettingItem({
              icon: '💾',
              title: '数据备份',
              subtitle: '导出账单数据到本地',
              onClick: () => {
                // 导出数据
              }
            })

            NavigationSettingItem({
              icon: '📥',
              title: '数据恢复',
              subtitle: '从备份文件恢复数据',
              onClick: () => {
                // 导入数据
              }
            })

            NavigationSettingItem({
              icon: '🗑️',
              title: '清除数据',
              subtitle: '删除所有账单数据',
              onClick: () => {
                // 清除数据
              }
            })
          }

          // 关于组
          SettingsGroup({ title: '关于' }) {
            InfoSettingItem({
              icon: 'ℹ️',
              title: '版本',
              value: '1.0.0'
            })

            NavigationSettingItem({
              icon: '📖',
              title: '使用帮助',
              subtitle: '了解如何使用自动记账',
              onClick: () => {
                // 打开帮助
              }
            })

            NavigationSettingItem({
              icon: '📧',
              title: '意见反馈',
              subtitle: '向我们反馈问题和建议',
              onClick: () => {
                // 打开反馈
              }
            })
          }
        }
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}

// 设置组
@Component
struct SettingsGroup {
  @BuilderParam content: () => void
  @Prop title: string

  build() {
    Column({ space: 8 }) {
      Text(this.title)
        .fontSize(14)
        .fontColor('#999')
        .alignSelf(ItemAlign.Start)
        .margin({ left: 8 })

      Column() {
        this.content()
      }
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius(12)
      .shadow({ radius: 4, color: 'rgba(0,0,0,0.05)' })
    }
    .width('100%')
  }
}

// 开关设置项
@Component
struct ToggleSettingItem {
  @Prop icon: string
  @Prop title: string
  @Prop subtitle: string
  @Prop isOn: boolean
  onChange: (value: boolean) => void = () => {}

  build() {
    Row() {
      Text(this.icon)
        .fontSize(24)
        .margin({ right: 12 })

      Column({ space: 4 }) {
        Text(this.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Text(this.subtitle)
          .fontSize(12)
          .fontColor('#999')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Toggle({ type: ToggleType.Switch, isOn: this.isOn })
        .onChange((value) => {
          this.onChange(value)
        })
    }
    .width('100%')
    .height(64)
    .padding(12)
  }
}

// 导航设置项
@Component
struct NavigationSettingItem {
  @Prop icon: string
  @Prop title: string
  @Prop subtitle: string
  onClick: () => void = () => {}

  build() {
    Row() {
      Text(this.icon)
        .fontSize(24)
        .margin({ right: 12 })

      Column({ space: 4 }) {
        Text(this.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Text(this.subtitle)
          .fontSize(12)
          .fontColor('#999')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text('>')
        .fontSize(18)
        .fontColor('#CCC')
    }
    .width('100%')
    .height(64)
    .padding(12)
    .onClick(this.onClick)
  }
}

// 信息设置项
@Component
struct InfoSettingItem {
  @Prop icon: string
  @Prop title: string
  @Prop value: string

  build() {
    Row() {
      Text(this.icon)
        .fontSize(24)
        .margin({ right: 12 })

      Text(this.title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)

      Text(this.value)
        .fontSize(14)
        .fontColor('#999')
    }
    .width('100%')
    .height(56)
    .padding(12)
  }
}