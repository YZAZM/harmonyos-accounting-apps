import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct Settings {
  @State autoRecordEnabled: boolean = false;
  @State floatingWindowEnabled: boolean = true;
  @State isAccessibilityEnabled: boolean = false;

  aboutToAppear() {
    // 检查无障碍服务状态
    this.checkAccessibilityStatus();
  }

  // 检查无障碍服务是否开启
  checkAccessibilityStatus() {
    // 实际实现需要调用系统API检查
    this.isAccessibilityEnabled = false;
  }

  // 跳转到无障碍设置
  openAccessibilitySettings() {
    const context = getContext(this) as common.UIAbilityContext;
    const want: Want = {
      action: 'action.settings.accessibility'
    };
    context.startAbility(want).catch((err: BusinessError) => {
      console.error('打开无障碍设置失败:', JSON.stringify(err));
    });
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('＜')
          .fontSize(24)
          .fontColor('#666666')
          .onClick(() => {
            router.back();
          })
        
        Text('设置')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
        
        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })

      Scroll() {
        Column({ space: 16 }) {
          // 自动记账功能区
          this.AutoRecordSection()

          // 数据管理区
          this.DataManagementSection()

          // 关于应用
          this.AboutSection()
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  AutoRecordSection() {
    Column({ space: 12 }) {
      Text('自动记账')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1A1A')
        .alignSelf(ItemAlign.Start)
      
      Column({ space: 0 }) {
        // 自动记账开关
        Row() {
          Column({ space: 2 }) {
            Text('开启自动记账')
              .fontSize(15)
              .fontColor('#1A1A1A')
            
            Text('自动识别支付页面并弹出确认')
              .fontSize(12)
              .fontColor('#999999')
          }
          .alignItems(HorizontalAlign.Start)
          
          Blank()
          
          Toggle({ type: ToggleType.Switch, isOn: this.autoRecordEnabled })
            .selectedColor('#4CAF50')
            .onChange((isOn: boolean) => {
              this.autoRecordEnabled = isOn;
              if (isOn && !this.isAccessibilityEnabled) {
                // 提示开启无障碍服务
                this.openAccessibilitySettings();
              }
            })
        }
        .width('100%')
        .height(60)
        .padding({ left: 16, right: 16 })

        Divider()
          .color('#F0F0F0')
          .margin({ left: 16, right: 16 })

        // 无障碍服务状态
        Row() {
          Column({ space: 2 }) {
            Text('无障碍服务')
              .fontSize(15)
              .fontColor('#1A1A1A')
            
            Text(this.isAccessibilityEnabled ? '已开启' : '未开启')
              .fontSize(12)
              .fontColor(this.isAccessibilityEnabled ? '#4CAF50' : '#FF5722')
          }
          .alignItems(HorizontalAlign.Start)
          
          Blank()
          
          if (!this.isAccessibilityEnabled) {
            Text('去开启 ＞')
              .fontSize(13)
              .fontColor('#4CAF50')
              .onClick(() => {
                this.openAccessibilitySettings();
              })
          }
        }
        .width('100%')
        .height(60)
        .padding({ left: 16, right: 16 })

        Divider()
          .color('#F0F0F0')
          .margin({ left: 16, right: 16 })

        // 悬浮窗开关
        Row() {
          Column({ space: 2 }) {
            Text('悬浮确认窗')
              .fontSize(15)
              .fontColor('#1A1A1A')
            
            Text('支付后弹出确认窗口')
              .fontSize(12)
              .fontColor('#999999')
          }
          .alignItems(HorizontalAlign.Start)
          
          Blank()
          
          Toggle({ type: ToggleType.Switch, isOn: this.floatingWindowEnabled })
            .selectedColor('#4CAF50')
            .onChange((isOn: boolean) => {
              this.floatingWindowEnabled = isOn;
            })
        }
        .width('100%')
        .height(60)
        .padding({ left: 16, right: 16 })
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .clip(true)

      // 提示信息
      Row({ space: 8 }) {
        Text('💡')
          .fontSize(16)
        
        Text('自动记账需要开启无障碍服务和悬浮窗权限才能正常工作')
          .fontSize(12)
          .fontColor('#999999')
          .layoutWeight(1)
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#FFF9E6')
      .borderRadius(8)
    }
    .width('100%')
  }

  @Builder
  DataManagementSection() {
    Column({ space: 12 }) {
      Text('数据管理')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1A1A')
        .alignSelf(ItemAlign.Start)
      
      Column({ space: 0 }) {
        // 数据导出
        Row() {
          Text('导出数据')
            .fontSize(15)
            .fontColor('#1A1A1A')
          
          Blank()
          
          Text('＞')
            .fontSize(16)
            .fontColor('#CCCCCC')
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .onClick(() => {
          // 导出数据逻辑
        })

        Divider()
          .color('#F0F0F0')
          .margin({ left: 16, right: 16 })

        // 数据导入
        Row() {
          Text('导入数据')
            .fontSize(15)
            .fontColor('#1A1A1A')
          
          Blank()
          
          Text('＞')
            .fontSize(16)
            .fontColor('#CCCCCC')
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .onClick(() => {
          // 导入数据逻辑
        })

        Divider()
          .color('#F0F0F0')
          .margin({ left: 16, right: 16 })

        // 清除数据
        Row() {
          Text('清除所有数据')
            .fontSize(15)
            .fontColor('#FF5722')
          
          Blank()
          
          Text('＞')
            .fontSize(16)
            .fontColor('#CCCCCC')
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .onClick(() => {
          // 清除数据逻辑
        })
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .clip(true)
    }
    .width('100%')
  }

  @Builder
  AboutSection() {
    Column({ space: 12 }) {
      Text('关于')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1A1A')
        .alignSelf(ItemAlign.Start)
      
      Column({ space: 0 }) {
        // 版本信息
        Row() {
          Text('版本号')
            .fontSize(15)
            .fontColor('#1A1A1A')
          
          Blank()
          
          Text('1.0.0')
            .fontSize(14)
            .fontColor('#999999')
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })

        Divider()
          .color('#F0F0F0')
          .margin({ left: 16, right: 16 })

        // 隐私政策
        Row() {
          Text('隐私政策')
            .fontSize(15)
            .fontColor('#1A1A1A')
          
          Blank()
          
          Text('＞')
            .fontSize(16)
            .fontColor('#CCCCCC')
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })

        Divider()
          .color('#F0F0F0')
          .margin({ left: 16, right: 16 })

        // 用户协议
        Row() {
          Text('用户协议')
            .fontSize(15)
            .fontColor('#1A1A1A')
          
          Blank()
          
          Text('＞')
            .fontSize(16)
            .fontColor('#CCCCCC')
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .clip(true)
    }
    .width('100%')
  }
}
