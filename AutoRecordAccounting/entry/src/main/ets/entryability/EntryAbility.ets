import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit'
import { window } from '@kit.ArkUI'
import { DatabaseManager } from '../database/DatabaseManager'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    console.info('EntryAbility onCreate')
    // 初始化数据库
    DatabaseManager.getInstance().init().then(() => {
      console.info('数据库初始化完成')
    }).catch((err: Error) => {
      console.error('数据库初始化失败:', err)
    })
  }

  onDestroy(): void {
    console.info('EntryAbility onDestroy')
    DatabaseManager.getInstance().close()
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    console.info('EntryAbility onWindowStageCreate')
    
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        console.error('加载页面失败:', err)
        return
      }
      console.info('页面加载成功')
    })
  }

  onWindowStageDestroy(): void {
    console.info('EntryAbility onWindowStageDestroy')
  }

  onForeground(): void {
    console.info('EntryAbility onForeground')
  }

  onBackground(): void {
    console.info('EntryAbility onBackground')
  }
}