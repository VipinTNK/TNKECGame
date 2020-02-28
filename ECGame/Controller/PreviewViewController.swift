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
    var selectedStockIds = "4,5,7"
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
        self.showHUD(progressLabel: AlertField.loaderString)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.getRoadmapDataFromServer(stockIDs: selectedStockIds)
    }
    
    //MARK: - Initials -
    func loadBasicView() -> Void {
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
    }
    
    func setdefaultStock() -> Void {
        self.stockLbl.text = Stock.CryptoCurrency.localiz()
        self.BTULbl.text = Stock.BTCUSDT.localiz()
        appDelegate.sharedInstance.selectedStockname = Stock.CryptoCurrency
        appDelegate.sharedInstance.selectedBTUName = Stock.BTCUSDT
        appDelegate.sharedInstance.selectedTimeLoop = Stock.oneMinutes
    }
    
    //MARK: - Button Outlet -
    @IBAction func backBtnClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
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
        for index in 0..<tableArray.count {
            let stock = tableArray[index]  as! [String : Any]
            if stock["previewStockStatus"] as! String == "open" {
                let view = self.getMainStoryBoardSharedInstance().instantiateViewController(withIdentifier: GameViewController.className()) as! GameViewController
                let idArray = selectedStockIds.components(separatedBy: ",")
                view.selectedStockId = idArray[index]
                view.timeloop = self.timeloop
                view.updateLocaleClosure = { () in
                    self.updateFlagForSelectedLanguage()
                    self.updateTextOnLanguageChange()
                }
                self.navigationController?.pushViewController(view, animated: true)
                break;
            }
        }
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { () in
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
    
    func createGamePreviewList(stockTypeList : [RoadmapStockTypeModel])-> [Any] {
           var gamePreviewList = [Any]()
           for stock in stockTypeList {
               var stockDetails = [String :Any]()
               let itemArray = RoadmapManager.getLastElements(array: stock.stockData!, count: 30)
               stock.stockData! = []
               stock.stockData! = itemArray
               stockDetails["previewStockCategory"] =  stock.stockCategory
               stockDetails["previewStockName"] =  stock.stockName
               stockDetails["previewStockStatus"] =  stock.status
               stockDetails["previewStockData"] = RoadmapManager.createGridArrayForRoadmap(roadmapDataArray: stock.stockData!, withSelectedRoadmapType: 1)
               gamePreviewList.append(stockDetails)
           }
           return gamePreviewList
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
      func getRoadmapDataFromServer(stockIDs : String) {
          if NetworkManager.sharedInstance.isInternetAvailable(){
              let stateURL : String = UrlName.baseUrl + UrlName.roadmapListUrl
              let params = ["stockId" : "4,5,7"]  as [String : Any]
              NetworkManager.sharedInstance.commonNetworkCallWithHeader(header: [:], url: stateURL, method: .post, parameters: params, completionHandler: { (json, status) in
                  guard let jsonValue = json else {
                      self.dismissHUD(isAnimated: true)
                      return
                  }
                  self.roadMapModel = Mapper<RoadmapModel>().map(JSONObject: jsonValue)
                  if  self.roadMapModel?.code == 200, self.roadMapModel!.status {
                     if let list = self.roadMapModel?.data![0].roadMap, !list.isEmpty {
                          self.tableArray = []
                          self.tableArray = self.createGamePreviewList(stockTypeList: list)
                          self.previewTableView.reloadData()
                      }
                  }
                  self.dismissHUD(isAnimated: true)
              })
          } else {
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
      
        let stcokObject =  tableArray[indexPath.row] as! [String : Any]
        let collectionArray = stcokObject["previewStockData"] as! [FirstDigitItems]
      
        // Labels inside cells
        cell?.label1.backgroundColor = .clear
        cell?.contentView.bringSubviewToFront(cell!.label1)
        cell?.label1.text = String(stcokObject["previewStockCategory"] as! String).uppercased()
        cell?.label2.text = String(stcokObject["previewStockName"] as! String).uppercased()
        cell?.label3.text = self.roadMapModel?.data![0].roadMap![indexPath.row].stockData?.last?.gameId
        cell?.label4.text = self.roadMapModel?.data![0].roadMap![indexPath.row].stockData?.last?.PT
      
        // Data managing inside collection views
        cell?.collectionDataArray = collectionArray
        cell?.numberCollectionView.reloadData()
        cell?.bigSmallCollectionView.reloadData()
        cell?.evenOddCollectionView.reloadData()
        cell?.upmidhighCollectionView.reloadData()
        
        // Tap gesture to navigate Game Screen
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        cell?.contentView.tag = indexPath.row
        cell?.contentView.addGestureRecognizer(tap)
    
        // Manage stock button to show status of stock
        if stcokObject["previewStockStatus"] as! String == "open" {
            cell?.stockClosedBtn.isHidden = true
        } else {
            cell?.stockClosedBtn.isHidden = false
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.movetoGameClicked(menuButton)
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        let stock = tableArray[sender!.view!.tag]  as! [String : Any]
        if stock["previewStockStatus"] as! String == "open" {
            if BTULbl.text?.localiz() == Stock.selectBTU.localiz() {
                self.makeToastInBottomWithMessage(AlertField.emptyStockString)
                return
            }
            //Added code for pods
            let view = self.getMainStoryBoardSharedInstance().instantiateViewController(withIdentifier: GameViewController.className()) as! GameViewController
            let idArray = selectedStockIds.components(separatedBy: ",")
            view.selectedStockId = idArray[sender!.view!.tag]
            view.betDigitString = BetDigit.firstdigit
            if idArray[sender!.view!.tag] == "4" {
                appDelegate.sharedInstance.selectedStockname = Stock.ChinaStock
                appDelegate.sharedInstance.selectedBTUName = Stock.SZ399001
                appDelegate.sharedInstance.selectedTimeLoop = Stock.fiveMinutes
                view.timeloop = 300
            }
            else if idArray[sender!.view!.tag] == "5" {
                appDelegate.sharedInstance.selectedStockname = Stock.USStock
                appDelegate.sharedInstance.selectedBTUName = Stock.USDollarIndiex
                appDelegate.sharedInstance.selectedTimeLoop = Stock.fiveMinutes
                view.timeloop = 300
            }
            else {
                appDelegate.sharedInstance.selectedStockname = Stock.CryptoCurrency
                appDelegate.sharedInstance.selectedBTUName = Stock.BTCUSDT
                appDelegate.sharedInstance.selectedTimeLoop = Stock.oneMinutes
                view.timeloop = 60
            }
            self.navigationController?.pushViewController(view, animated: true)
        }
    }
}

extension PreviewViewController {
    func initialSetup() {
        UserDefaults.standard.set(false, forKey: UserDefaultsKey.isProfileShow)
        IQKeyboardManager.shared.enable = true
        let islangSet = UserDefaults.init().bool(forKey: UserDefaultsKey.isLanguageDefinded)
        if !islangSet {
            LanguageManager.shared.defaultLanguage = .en
            LanguageManager.shared.currentLanguage = .en
        }
    }
}
