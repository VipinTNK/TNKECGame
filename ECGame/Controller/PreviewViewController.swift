//
//  PreviewViewController.swift
//  ECGame
//
//  Created by iOS TNK on 27/01/20.
//  Copyright © 2020 tnk. All rights reserved.
//

import UIKit
import AVFoundation
import DropDown
import ObjectMapper
import IQKeyboardManagerSwift

class PreviewViewController: UIViewController, LanguageDelegate, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - IBoutlet -
    @IBOutlet weak var previewTableView: UITableView!
    @IBOutlet weak var musicButton: UIButton!
    @IBOutlet weak var languageButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var stockLbl: UILabel!
    @IBOutlet weak var BTULbl: UILabel!
    @IBOutlet weak var gamingLbl: UILabel!
    @IBOutlet weak var gameIntroLbl: UILabel!
    //Notification component
    @IBOutlet weak var notificationBgView: UIView!
    @IBOutlet weak var notificationLbl: UILabel!
    @IBOutlet weak var notificationImgView: UIImageView!
    //MARK: - Variables -
    var languagePopupView = LanguageView()
    var player : AVAudioPlayer?
    let dropDownObj = DropDown()
    var notificationModel : NotificationModel?
    var selectedStockId = 7
    var timeloop = 60
    var notifCounter = 0
    var roadMapModel : RoadmapModel?
    var tableArray = [Any]()
    
    //MARK: - View Life -
    override func loadView() {
        super.loadView()
        initialSetup()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadBasicView()
    }
    
    //MARK: - Initials -
    func loadBasicView() -> Void {
        self.creatDropdownRoadmap()
        self.updateFlagForSelectedLanguage()
        self.setdefaultStock()
        previewTableView.delegate = self
        previewTableView.dataSource = self
        //Added code for pods
        let bundle = self.initialiseBundle(ClassString: PreviewTableCell.className())
        previewTableView.register(UINib(nibName: PreviewTableCell.className(), bundle: bundle), forCellReuseIdentifier: PreviewTableCell.className())
        previewTableView.bounces = false
        self.gamingLbl.text = NavigationTitle.gamingString.localiz()
        self.gameIntroLbl.text = NavigationTitle.gameIntroString.localiz()
        //Add properties in notificationView
        self.notificationBgView.setCornerRadiusOfView(cornerRadiusValue: 10)
        self.getNotificationAPI()
        self.getRoadmapDataFromServer(stockID: selectedStockId)
    }
    
    func setdefaultStock() -> Void {
        self.stockLbl.text = Stock.CryptoCurrency.localiz()
        self.BTULbl.text = Stock.BTCUSDT.localiz()
        appDelegate.sharedInstance.selectedStockname = Stock.CryptoCurrency
        appDelegate.sharedInstance.selectedBTUName = Stock.BTCUSDT
        appDelegate.sharedInstance.selectedTimeLoop = Stock.oneMinutes
    }
    
    //MARK: - Button Outlet -
    @IBAction func languageBtnClicked(_ sender: UIButton) {
        self.getLanguageBtnAction(sender)
    }
    @IBAction func musicBtnClicked(_ sender: UIButton) {
        self.getMusicBtnAction(sender)
    }
    @IBAction func movetoGameClicked(_ sender: UIButton) {
        self.getMovetoGameAction(sender)
    }
    @IBAction func stockBtnClicked(_ sender: UIButton) {
        self.selectfromDropdown(sender: sender)
    }
    
    //MARK: - Button Methods -
    func getLanguageBtnAction(_ sender: UIButton) {
        self.getLaunguageChnageBtnAction(sender: sender)
    }
    func getMusicBtnAction(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            player?.stop()
        }
        else {
            sender.isSelected = true
            //Added code for pods
            let bundle = Bundle.init(for: self.classForCoder)
            let path = bundle.path(forResource: AssetResource.welcomeSound, ofType : AssetName.mp3String)!
            let url = URL(fileURLWithPath : path)
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.play()
                
            } catch {
                print ("Error in music load")
            }
        }
    }
    func getMovetoGameAction(_ sender: UIButton) {
        let view = self.getMainStoryBoardSharedInstance().instantiateViewController(withIdentifier: GameViewController.className()) as! GameViewController
        view.selectedStockId = self.selectedStockId
        view.timeloop = self.timeloop
        view.updateLocaleClosure = { () in
            self.updateFlagForSelectedLanguage()
            self.updateTextOnLanguageChange()
        }
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    //MARK:- Notification -
    func showNotifications() -> Void {
        if notifCounter < notificationModel?.data?.count ?? 0 {
            let list = self.notificationModel?.data
            UIView.transition(with: self.notificationLbl,
                              duration: 1.5,
                              options: .transitionFlipFromLeft,
                              animations: { [weak self] in
                                self?.notificationLbl.text = list?[(self?.notifCounter)!].message
                }, completion: nil)
            notifCounter = notifCounter + 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [unowned self] in
                self.showNotifications()
            }
        }
    }
    
    //MARK: - Custom Method -
    func getLaunguageChnageBtnAction(sender : UIButton)  {
        //Added code for pods
        let bundle = self.initialiseBundle(ClassString: LanguageView.className())
        languagePopupView = bundle.loadNibNamed(LanguageView.className(), owner: self, options: nil)?[0] as! LanguageView
        languagePopupView.languageDelegate = self
        languagePopupView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        languagePopupView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.view.addSubview(languagePopupView)
        languagePopupView.layer.zPosition = 1
        languagePopupView.popIn()
        self.view.bringSubviewToFront(languagePopupView)
    }
    
    func updateFlagForSelectedLanguage() -> Void {
        //Added code for pods
        var tempFlagImage : UIImage?
        if UserDefaults.standard.bool(forKey: UserDefaultsKey.isLanguageDefinded) {
            if LanguageManager.shared.currentLanguage == .en {
                tempFlagImage = UIImage.init(named: AssetName.usaFlag, in: Bundle.init(for: self.classForCoder), compatibleWith: nil)
            }
            else if LanguageManager.shared.currentLanguage == .th {
                tempFlagImage = UIImage.init(named: AssetName.thaiFlag, in: Bundle.init(for: self.classForCoder), compatibleWith: nil)
            }
            else if LanguageManager.shared.currentLanguage == .lao {
                tempFlagImage = UIImage.init(named: AssetName.laoFlag, in: Bundle.init(for: self.classForCoder), compatibleWith: nil)
            }
            else if LanguageManager.shared.currentLanguage == .zhHans {
                tempFlagImage = UIImage.init(named: AssetName.chinaFlag, in: Bundle.init(for: self.classForCoder), compatibleWith: nil)
            }
        }
        else {
            tempFlagImage = UIImage.init(named: AssetName.usaFlag, in: Bundle.init(for: self.classForCoder), compatibleWith: nil)
        }
        languageButton.setImage(tempFlagImage, for: .normal)
    }
    
    //MARK: - Refresh Text for Multi Language support -
    func updateTextOnLanguageChange() -> Void {
        self.gamingLbl.text = NavigationTitle.gamingString.localiz()
        self.gameIntroLbl.text = NavigationTitle.gameIntroString.localiz()
        self.stockLbl.text = appDelegate.sharedInstance.selectedStockname.localiz()
        self.BTULbl.text = appDelegate.sharedInstance.selectedBTUName.localiz()
        self.previewTableView.reloadData()
    }
    
    //MARK: - Delegate -
    func changeSelectedLanguage(selectedLanguageIndex: Int) {
        //Added code for pods
        var tempFlagImage : UIImage?
        if selectedLanguageIndex == 1 {
            tempFlagImage = UIImage.init(named: AssetName.usaFlag, in: Bundle.init(for: self.classForCoder), compatibleWith: nil)
            LanguageManager.shared.currentLanguage = .en
        } else if selectedLanguageIndex == 4 {
            tempFlagImage = UIImage.init(named: AssetName.thaiFlag, in: Bundle.init(for: self.classForCoder), compatibleWith: nil)
            LanguageManager.shared.currentLanguage = .th
        } else if selectedLanguageIndex == 3 {
            tempFlagImage = UIImage.init(named: AssetName.laoFlag, in: Bundle.init(for: self.classForCoder), compatibleWith: nil)
            LanguageManager.shared.currentLanguage = .lao
        } else { //2 for china
            tempFlagImage = UIImage.init(named: AssetName.chinaFlag, in: Bundle.init(for: self.classForCoder), compatibleWith: nil)
            LanguageManager.shared.currentLanguage = .zhHans
        }
        languageButton.setImage(tempFlagImage, for: .normal)
        UserDefaults.init().set(true, forKey: UserDefaultsKey.isLanguageDefinded)
        self.updateTextOnLanguageChange()
    }
    
    //MARK: - Dropdown Actions -
    func selectfromDropdown(sender : UIButton) {
        self.view.endEditing(true)
        dropDownObj.anchorView = stockLbl
        if sender.tag == 9 {
            dropDownObj.tag = 9
            dropDownObj.width = stockLbl.frame.width + 15
            dropDownObj.dataSource = [Stock.USStock.localiz(), Stock.ChinaStock.localiz(), Stock.CryptoCurrency.localiz()]
            appDelegate.sharedInstance.dropdownArray = [Stock.USStock, Stock.ChinaStock, Stock.CryptoCurrency]
        }
        else if sender.tag == 10 {
            dropDownObj.tag = 10
            dropDownObj.anchorView = BTULbl
            dropDownObj.width = BTULbl.frame.width + 20
            let selectedStock = stockLbl.text?.localiz()
            if selectedStock == Stock.USStock.localiz() {
                dropDownObj.dataSource = [Stock.USDollarIndiex.localiz()]
                appDelegate.sharedInstance.dropdownArray = [Stock.USDollarIndiex]
            }
            else if selectedStock == Stock.ChinaStock.localiz() {
                dropDownObj.dataSource = [Stock.SH000001, Stock.SZ399001, Stock.SZ399415, Stock.SH000300]
                appDelegate.sharedInstance.dropdownArray = [Stock.SH000001, Stock.SZ399001, Stock.SZ399415, Stock.SH000300]
            }
            else if selectedStock == Stock.CryptoCurrency.localiz() {
                dropDownObj.dataSource = [Stock.BTCUSDT.localiz()]
                appDelegate.sharedInstance.dropdownArray = [Stock.BTCUSDT]
            }
            else {
                self.makeToastInBottomWithMessage(AlertField.emptyStockString)
                return
            }
        }
        dropDownObj.show()
    }
    
    //MARK: - Drop Down -
    func creatDropdownRoadmap()  {
        
        self.view.bringSubviewToFront(dropDownObj)
        dropDownObj.cornerRadius = 10
        dropDownObj.textFont = UIFont.init(name: "Optima", size: 11.0)!
        dropDownObj.textColor = CommonMethods.hexStringToUIColor(hex: Color.dropdownTextColor)
        
        dropDownObj.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.dropDownObj.hide()
            if self.dropDownObj.tag == 9 {
                self.stockLbl.text = appDelegate.sharedInstance.dropdownArray[index].localiz() //item.localiz()
                self.BTULbl.text = Stock.selectBTU.localiz()
                appDelegate.sharedInstance.selectedStockname = appDelegate.sharedInstance.dropdownArray[index]
            }
            else if self.dropDownObj.tag == 10 {
                self.stockLbl.text = appDelegate.sharedInstance.selectedStockname.localiz()
                self.BTULbl.text = appDelegate.sharedInstance.dropdownArray[index].localiz()
                appDelegate.sharedInstance.selectedBTUName = appDelegate.sharedInstance.dropdownArray[index]
                if appDelegate.sharedInstance.selectedStockname == Stock.USStock {
                    self.selectedStockId = 5
                    self.timeloop = 300
                    appDelegate.sharedInstance.selectedTimeLoop = Stock.fiveMinutes
                }
                else if appDelegate.sharedInstance.selectedStockname == Stock.ChinaStock {
                    if appDelegate.sharedInstance.selectedBTUName == Stock.SH000001 {
                        self.selectedStockId = 1
                        self.timeloop = 300
                        appDelegate.sharedInstance.selectedTimeLoop = Stock.fiveMinutes
                    }
                    else if appDelegate.sharedInstance.selectedBTUName == Stock.SZ399001 {
                        self.selectedStockId = 4
                        self.timeloop = 300
                        appDelegate.sharedInstance.selectedTimeLoop = Stock.fiveMinutes
                    }
                    else if appDelegate.sharedInstance.selectedBTUName == Stock.SZ399415 {
                        self.selectedStockId = 3
                        self.timeloop = 300
                        appDelegate.sharedInstance.selectedTimeLoop = Stock.fiveMinutes
                    }
                    else if appDelegate.sharedInstance.selectedBTUName == Stock.SH000300 {
                        self.selectedStockId = 2
                        self.timeloop = 300
                        appDelegate.sharedInstance.selectedTimeLoop = Stock.fiveMinutes
                    }
                }
                else if appDelegate.sharedInstance.selectedStockname == Stock.CryptoCurrency {
                    self.selectedStockId = 7
                    self.timeloop = 60
                    appDelegate.sharedInstance.selectedTimeLoop = Stock.oneMinutes
                }
                self.getRoadmapDataFromServer(stockID: self.selectedStockId)
            }
        }
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
//MARK: - API Call -
extension PreviewViewController {
    
    //Header Notification -
    func getNotificationAPI() {
        if NetworkManager.sharedInstance.isInternetAvailable(){
            let betURL : String = UrlName.baseUrl + UrlName.notificationUrl
            NetworkManager.sharedInstance.commonNetworkCallWithHeader(header: [:], url: betURL, method: .post, parameters: nil, completionHandler: { (json, status) in
                guard let jsonValue = json else {
                    self.dismissHUD(isAnimated: true)
                    return
                }
                self.notificationModel = Mapper<NotificationModel>().map(JSONObject: jsonValue)
                if  self.notificationModel?.code == 200, self.notificationModel!.status {
                    if let list = self.notificationModel?.data, !list.isEmpty {
                        self.notifCounter = 0
                        self.showNotifications()
                    }
                }
                else {
                    //self.makeToastInBottomWithMessage(self.notificationModel?.message.capitalized ?? "")
                }
            })
        }else{
            self.showNoInternetAlert()
        }
    }
    
    // API call for roadmap view
      func getRoadmapDataFromServer(stockID : Int) {
          if NetworkManager.sharedInstance.isInternetAvailable(){
              self.showHUD(progressLabel: AlertField.loaderString)
              let stateURL : String = UrlName.baseUrl + UrlName.roadMapUrl
              let params = ["stockId" : stockID]  as [String : Any]
              NetworkManager.sharedInstance.commonNetworkCallWithHeader(header: [:], url: stateURL, method: .post, parameters: params, completionHandler: { (json, status) in
                  guard let jsonValue = json else {
                      self.dismissHUD(isAnimated: true)
                      return
                  }
                  self.roadMapModel = Mapper<RoadmapModel>().map(JSONObject: jsonValue )
                  
                  if  self.roadMapModel?.code == 200, self.roadMapModel!.status {
                      if let list = self.roadMapModel?.data![0].roadMap, !list.isEmpty {
                        
                          self.roadMapModel?.data![0].roadMap = []
                          self.roadMapModel?.data![0].roadMap = RoadmapManager.getLastElements(array: list, count: 28)
                          self.tableArray = []
                          self.tableArray.append(RoadmapManager.createGridArrayForRoadmap(roadmapDataArray: self.roadMapModel!.data![0].roadMap!, withSelectedRoadmapType: 4))
                         self.tableArray.append(RoadmapManager.createGridArrayForRoadmap(roadmapDataArray: self.roadMapModel!.data![0].roadMap!, withSelectedRoadmapType: 1))
                         self.tableArray.append(RoadmapManager.createGridArrayForRoadmap(roadmapDataArray: self.roadMapModel!.data![0].roadMap!, withSelectedRoadmapType: 2))
                         self.previewTableView.reloadData()
                      }
                  }
                  self.dismissHUD(isAnimated: true)
              })
          }else{
              self.showNoInternetAlert()
          }
      }
}

extension PreviewViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = previewTableView.dequeueReusableCell(withIdentifier: PreviewTableCell.className()) as? PreviewTableCell
        if cell == nil {
            //Added code for pods
            let bundle = self.initialiseBundle(ClassString: PreviewTableCell.className())
            previewTableView.register(UINib(nibName: PreviewTableCell.className(), bundle: bundle), forCellReuseIdentifier: PreviewTableCell.className())
           }
        cell?.label1.backgroundColor = .clear
        cell?.contentView.bringSubviewToFront(cell!.label1)
        if indexPath.row == 0 {
            cell?.label1.text = buttonTitle.roadmapbothDigitString.localiz()
        } else if indexPath.row == 1 {
            cell?.label1.text = buttonTitle.roadmapfirstDigitString.localiz()
        } else if indexPath.row == 2 {
            cell?.label1.text = buttonTitle.roadmaplastDigitString.localiz()
        }
        
        cell?.label4.text = appDelegate.sharedInstance.selectedStockname.localiz()
        cell?.label5.text = appDelegate.sharedInstance.selectedBTUName.localiz()
       
        cell?.collectionDataArray = tableArray[indexPath.row] as! [FirstDigitItems]
        cell?.numberCollectionView.reloadData()
        cell?.bigSmallCollectionView.reloadData()
        cell?.evenOddCollectionView.reloadData()
        cell?.upmidhighCollectionView.reloadData()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        cell?.contentView.tag = indexPath.row
        cell?.contentView.addGestureRecognizer(tap)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.movetoGameClicked(menuButton)
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if BTULbl.text?.localiz() == Stock.selectBTU.localiz() {
            self.makeToastInBottomWithMessage(AlertField.emptyStockString)
            return
        }
        //Added code for pods
        let view = self.getMainStoryBoardSharedInstance().instantiateViewController(withIdentifier: GameViewController.className()) as! GameViewController
        view.selectedStockId = self.selectedStockId
        view.timeloop = self.timeloop
        if sender?.view?.tag == 0 {
            view.betDigitString = BetDigit.bothdigit
        }
        else if sender?.view?.tag == 1 {
            view.betDigitString = BetDigit.firstdigit
        }
        else if sender?.view?.tag == 2 {
            view.betDigitString = BetDigit.lastdigit
        }
        self.navigationController?.pushViewController(view, animated: true)
    }
}

extension PreviewViewController {
    
    func initialSetup(){
        UserDefaults.standard.set(false, forKey: UserDefaultsKey.isProfileShow)
        IQKeyboardManager.shared.enable = true
        let islangSet = UserDefaults.init().bool(forKey: UserDefaultsKey.isLanguageDefinded)
        if !islangSet {
            LanguageManager.shared.defaultLanguage = .en
            LanguageManager.shared.currentLanguage = .en
        }
    }
}
