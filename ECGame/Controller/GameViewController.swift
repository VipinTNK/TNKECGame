//
//  ViewController.swift
//  WhiteLabel
//
//  Created by hfcb on 22/09/1941 Saka.
//  Copyright © 1941 tnk. All rights reserved.
//

import UIKit
import AVFoundation
import DropDown
import Charts
import SimpleAnimation
import ObjectMapper
import AMPopTip

private class CubicLineSampleFillFormatter: IFillFormatter {
    func getFillLinePosition(dataSet: ILineChartDataSet, dataProvider: LineChartDataProvider) -> CGFloat {
        return -10
    }
}

class GameViewController: UIViewController, RoadMapDelegate, ChartViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, menuOpen, LanguageDelegate {
   
    //MARK:- IBOutlet
    @IBOutlet var chartView: LineChartView!
    @IBOutlet weak var chipsCollectionView : UICollectionView!
    @IBOutlet var circleView: UIView!
    @IBOutlet var stripSelectedView: UIView!
    @IBOutlet var BetInterfaceView: UIView!
    @IBOutlet var BetClearConfirmView: UIView!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var betVlaueLbl: UILabel!
    @IBOutlet weak var FDButton: UIButton!
    @IBOutlet weak var LDButton: UIButton!
    @IBOutlet weak var TDButton: UIButton!
    @IBOutlet weak var BDButton: UIButton!
    @IBOutlet weak var numberButton: UIButton!
    @IBOutlet weak var gamingLbl: UILabel!
    @IBOutlet weak var stockView: UIView!
    @IBOutlet weak var stockLbl: UILabel!
    @IBOutlet weak var BTULbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var stockTimerLbl: UILabel!
    @IBOutlet weak var musicButton: UIButton!
    @IBOutlet weak var languageButton: UIButton!
    @IBOutlet weak var numberView: UIView!
    @IBOutlet weak var numberFDButton: UIButton!
    @IBOutlet weak var numberLDButton: UIButton!
    @IBOutlet weak var numberTDButton: UIButton!
    @IBOutlet weak var numberBDButton: UIButton!
    @IBOutlet weak var lastdrawnFDLbl: UILabel!
    @IBOutlet weak var lastdrawnLDLbl: UILabel!
    //Digit Btn
    @IBOutlet weak var bigButton: UIButton!
    @IBOutlet weak var smallButton: UIButton!
    @IBOutlet weak var highButton: UIButton!
    @IBOutlet weak var lowButton: UIButton!
    @IBOutlet weak var midButton: UIButton!
    @IBOutlet weak var oddButton: UIButton!
    @IBOutlet weak var tieButton: UIButton!
    @IBOutlet weak var evenButton: UIButton!
    @IBOutlet weak var tieButtonWidthContraint: NSLayoutConstraint!
    //Notification component
    @IBOutlet weak var notificationBgView: UIView!
    @IBOutlet weak var notificationLbl: UILabel!
    @IBOutlet weak var userCreditLbl: UILabel!
    @IBOutlet weak var bellButton: UIButton!
    
    //MARK:- Variables -
    
    var chipsArray = [String]()
    var player : AVAudioPlayer?
    var mousePlayer : AVAudioPlayer?
    let dropDownObj = DropDown()
    var roadMapView = RoadMapView()
    var betCloseView = BetCloseView()
    var chiptaotalVlaue : Int = 0
    // Whether or not should use manager to present menu
    var sideMenuView = SideMenu()
    //Language popup object
    var languagePopupView = LanguageView()
    var graphArray :  [RoadmapDataObjectModel]?
    var roadMapModel : RoadmapModel?
    var stockListModel : StockListModel?
    var stockTimerModel : StockTimerModel?
    var storeBetModel : StoreBetModel?
    var notificationModel : NotificationModel?
    var currentBetResultModel : CurrentBetResultModel?
    var gameBetRuleString = ""
    var betDigitString = BetDigit.firstdigit      // First Digit, Last Digit ...
    var digitTypeString = ""     // Big, Small, even ...
    var selectedStockId = ""
    var timeloop = 60
    var timer: Timer?
    var notifCounter = 0
    var selelctedRow = -1
    let popTip = PopTip()
    var updateLocaleClosure : (() -> Void)?
     
    //MARK: - View life -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadBasicView()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.roadMapView.roadMaoDelegate = self
        self.getTimerInfoAPI()
        self.getNotificationAPI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
  
    //MARK: - Laod Intials - 
    func loadAllInitialViews() {
        //Roadmapview
        //Added code for pods
        let bundle = self.initialiseBundle(ClassString: RoadMapView.className())
        roadMapView = bundle.loadNibNamed(RoadMapView.className(), owner: self, options: nil)?[0] as! RoadMapView
        roadMapView.frame = CGRect(x: -8, y: -10, width: self.view.frame.size.width/2.15, height: self.view.frame.size.height/4.3)
        roadMapView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        roadMapView.layer.cornerRadius = 10
        roadMapView.layer.borderWidth = 1
        roadMapView.layer.borderColor = UIColor.white.cgColor
        roadMapView.layer.masksToBounds = true
        self.view.addSubview(roadMapView)
        //Show Loading
        self.showHUD(progressLabel: AlertField.loaderString)
        self.getRoadmapDataFromServer(stockID: selectedStockId)
    }
       
    func loadBasicView() {
       
        self.creatDropdownNewFile()
        self.createChartView()
        self.updateFlagForSelectedLanguage()
        self.setdefaultStock()
        self.circleView.isHidden = false
        self.numberView.isHidden = true
        self.gamingLbl.text = NavigationTitle.gamingString.localiz()
        self.numberFDButton.setmultipleLineTitle(titleString: buttonTitle.numberFirstDigitString.localiz().uppercased())
        self.numberLDButton.setmultipleLineTitle(titleString: buttonTitle.numberLastDigitString.localiz().uppercased())
        self.numberTDButton.setmultipleLineTitle(titleString: buttonTitle.numberTwoDigitString.localiz().uppercased())
        self.numberBDButton.setmultipleLineTitle(titleString: buttonTitle.numberBothDigitString.localiz().uppercased())
        self.FDButton.setmultipleLineTitle(titleString: buttonTitle.firstDigitString.localiz().uppercased())
        self.LDButton.setmultipleLineTitle(titleString: buttonTitle.lastDigitString.localiz().uppercased())
        self.TDButton.setmultipleLineTitle(titleString: buttonTitle.twoDigitString.localiz().uppercased())
        self.BDButton.setmultipleLineTitle(titleString: buttonTitle.bothDigitString.localiz().uppercased())
        self.numberButton.setmultipleLineTitle(titleString: buttonTitle.numberDigitString.localiz().uppercased())
        self.FDButton.backgroundColor = CommonMethods.hexStringToUIColor(hex: Color.btnSkyColor)
        self.LDButton.backgroundColor = CommonMethods.hexStringToUIColor(hex: Color.btnGreenColor)
        self.TDButton.backgroundColor = CommonMethods.hexStringToUIColor(hex: Color.btnYellowColor)
        self.BDButton.backgroundColor = CommonMethods.hexStringToUIColor(hex: Color.btnBlueColor)
        self.numberButton.backgroundColor = CommonMethods.hexStringToUIColor(hex: Color.btnVoiletColor)
        //Digit btn
        self.bigButton.setTitle(buttonTitle.bigBtnString.localiz(), for: .normal)
        self.smallButton.setTitle(buttonTitle.smallBtnString.localiz(), for: .normal)
        self.oddButton.setTitle(buttonTitle.oddBtnString.localiz(), for: .normal)
        self.evenButton.setTitle(buttonTitle.evenBtnString.localiz(), for: .normal)
        self.lowButton.setTitle(buttonTitle.lowBtnString.localiz(), for: .normal)
        self.highButton.setTitle(buttonTitle.highBtnString.localiz(), for: .normal)
        self.midButton.setTitle(buttonTitle.midBtnString.localiz(), for: .normal)
        //Bet Clear Confirm
        self.clearButton.setTitle(buttonTitle.claerBtnString.localiz(), for: .normal)
        self.confirmButton.setTitle(buttonTitle.confirmBtnString.localiz(), for: .normal)
        self.chipsArray = ["100", "500", "1000", "5000", "10000"]
        let cellSize = CGSize(width:50 , height:50)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 1.0
        layout.minimumInteritemSpacing = 1.0
        chipsCollectionView.setCollectionViewLayout(layout, animated: true)
        chipsCollectionView.bounces = false
        chipsCollectionView.reloadData()
        //Intialise and add all views
        loadAllInitialViews()
        //Create tooltip
        self.createTooltipforPayout()
    }

    func setdefaultStock() -> Void {
        
        self.stockLbl.text = appDelegate.sharedInstance.selectedStockname.localiz()
        self.BTULbl.text = appDelegate.sharedInstance.selectedBTUName.localiz()
        self.timeLbl.text = appDelegate.sharedInstance.selectedTimeLoop.localiz()
        if betDigitString == BetDigit.firstdigit {
            self.fisrtDigitBtnClicked(FDButton)
        }
        else if betDigitString == BetDigit.lastdigit {
            self.lastDigitBtnClicked(LDButton)
        }
        else if betDigitString == BetDigit.bothdigit {
            self.bothDigitBtnClicked(BDButton)
        }
    }
    
    //MARK: - IBActions -
    @IBAction func musicBtnClicked(_ sender: Any) {
        self.getmusicBtnAction(sender: sender as! UIButton)
    }
    @IBAction func changeLanguageAction(_ sender: Any) {
        self.getLaunguageChnageBtnAction(sender: sender as! UIButton)
    }
    @IBAction func menuBtnClicked(_ sender: Any) {
        self.getMenuBtnAction()
    }
    @IBAction func notificationBtnClicked(_ sender: UIButton) { //Confirm
        self.getNotificationBtnAction(sender: sender)
    }
    @IBAction func selectStockBtnClicked(_ sender: UIButton) {
        self.selectfromDropdown(sender: sender)
    }
    // Digit IBActions
    @IBAction func fisrtDigitBtnClicked(_ sender: UIButton) {
        circleView.isHidden = false
        numberView.isHidden = true
        self.getfisrtDigitBtnAction(sender)
    }
    @IBAction func lastDigitBtnClicked(_ sender: UIButton) {
        circleView.isHidden = false
        numberView.isHidden = true
        self.getlastDigitBtnAction(sender)
    }
    @IBAction func towDigitBtnClicked(_ sender: UIButton) {
        circleView.isHidden = false
        numberView.isHidden = true
        self.gettowDigitBtnAction(sender)
    }
    @IBAction func bothDigitBtnClicked(_ sender: UIButton) { //Sum
        circleView.isHidden = false
        numberView.isHidden = true
        self.getbothDigitBtnAction(sender)
    }
    @IBAction func numberDigitBtnClicked(_ sender: UIButton) { //Sum
        circleView.isHidden = true
        numberView.isHidden = false
        self.getnumberDigitBtnAction(sender)
    }
    //Bet on particular
    @IBAction func bigBtnClicked(_ sender: UIButton) {
        self.getbigBtnAction(sender)
    }
    @IBAction func smallBtnClicked(_ sender: UIButton) {
        self.getsmallBtnAction(sender)
    }
    @IBAction func lowBtnClicked(_ sender: UIButton) {
        self.getlowBtnAction(sender)
    }
    @IBAction func highBtnClicked(_ sender: UIButton) {
        self.gethighBtnAction(sender)
    }
    @IBAction func oddBtnClicked(_ sender: UIButton) {
        self.getoddBtnAction(sender)
    }
    @IBAction func tieBtnClicked(_ sender: UIButton) {
        self.gettieBtnAction(sender)
    }
    @IBAction func evenBtnClicked(_ sender: UIButton) {
        self.getevenBtnAction(sender)
    }
    @IBAction func midBtnClicked(_ sender: UIButton) {
        self.getmidBtnAction(sender)
    }
    //Number
    @IBAction func numberFirstDigitBtnClicked(_ sender: UIButton) {
        self.getNumberFirstDigitBtnAction(sender)
    }
    @IBAction func numberLastDigitBtnClicked(_ sender: UIButton) {
        self.getNumberLastDigitBtnAction(sender)
    }
    @IBAction func numberTwoDigitBtnClicked(_ sender: UIButton) {
        self.getNumberTwoDigitBtnAction(sender)
    }
    @IBAction func numberBothDigitBtnClicked(_ sender: UIButton) {
        self.getNumberBothDigitBtnAction(sender)
    }
    //Bet confirm /clear
    @IBAction func clearamountBtnClicked(_ sender: UIButton) { //Cancel
        self.getclearamountBtnAction(sender)
    }
    @IBAction func confirmBetBtnClicked(_ sender: UIButton) { //Confirm
        self.getconfirmBetBtnAction(sender)
    }
    
    //MARK: - IBActions  Methods-
    func getmusicBtnAction(sender : UIButton)  {
        self.navigationController?.popViewController(animated: true)
    }
    func getLaunguageChnageBtnAction(sender : UIButton) {
        //Added code for pods
        let bundle = self.initialiseBundle(ClassString: LanguageView.className())
        languagePopupView = bundle.loadNibNamed(LanguageView.className(), owner: self, options: nil)?[0] as! LanguageView
        languagePopupView.languageDelegate = self
        languagePopupView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        languagePopupView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.view.addSubview(languagePopupView)
        languagePopupView.layer.zPosition = 1
        languagePopupView.popIn()
        view.bringSubviewToFront(languagePopupView)
    }
    func getMenuBtnAction()  {
        //Added code for pods
        let bundle = self.initialiseBundle(ClassString: SideMenu.className())
        sideMenuView = bundle.loadNibNamed(SideMenu.className(), owner: self, options: nil)?[0] as! SideMenu
        sideMenuView.delegate = self
        sideMenuView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        sideMenuView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.view.addSubview(sideMenuView)
        sideMenuView.layer.zPosition = 1
        sideMenuView.popIn()
    }
    func getNotificationBtnAction(sender : UIButton)  {
        if sender.isSelected == true {
            sender.isSelected = false
            notificationBgView.isHidden = true
        }
        else if sender.isSelected == false {
            sender.isSelected = true
            notificationBgView.isHidden = false
        }
    }
    // Digit IBActions Methods
    func getfisrtDigitBtnAction(_ sender: UIButton) {
        betDigitString = BetDigit.firstdigit
        tieButtonWidthContraint.constant = 0
        //circleView.backgroundColor = CommonMethods.hexStringToUIColor(hex: Color.btnSkyColor)
        stripSelectedView.backgroundColor = CommonMethods.hexStringToUIColor(hex: Color.btnSkyColor)
    }
    func getlastDigitBtnAction(_ sender: UIButton) {
        betDigitString = BetDigit.lastdigit
        tieButtonWidthContraint.constant = 0
        //circleView.backgroundColor = CommonMethods.hexStringToUIColor(hex: Color.btnGreenColor)
        stripSelectedView.backgroundColor = CommonMethods.hexStringToUIColor(hex: Color.btnGreenColor)
    }
    func gettowDigitBtnAction(_ sender: UIButton) {
        betDigitString = BetDigit.twodigit
        tieButtonWidthContraint.constant = 81
        //circleView.backgroundColor = CommonMethods.hexStringToUIColor(hex: Color.btnYellowColor)
        stripSelectedView.backgroundColor = CommonMethods.hexStringToUIColor(hex: Color.btnYellowColor)
    }
    func getbothDigitBtnAction(_ sender: UIButton) {
        betDigitString = BetDigit.bothdigit
        tieButtonWidthContraint.constant = 81
        //circleView.backgroundColor = CommonMethods.hexStringToUIColor(hex: Color.btnBlueColor)
        stripSelectedView.backgroundColor = CommonMethods.hexStringToUIColor(hex: Color.btnBlueColor)
    }
    func getnumberDigitBtnAction(_ sender: UIButton) {
        //numberView.backgroundColor = CommonMethods.hexStringToUIColor(hex: Color.btnVoiletColor)
        stripSelectedView.backgroundColor = CommonMethods.hexStringToUIColor(hex: Color.btnVoiletColor)
    }
    //Bet on particular methods
    func getbigBtnAction(_ sender: UIButton) {
        digitTypeString = BetDigit.big
        self.showTooltip(textMessage: Payout.bigSmall.localiz(), tempBtn: sender, tempView: circleView, popDirection: .up)
        self.resetCircleViewButtonBackground(sender)
    }
    func getsmallBtnAction(_ sender: UIButton) {
        digitTypeString = BetDigit.small
        self.showTooltip(textMessage: Payout.bigSmall.localiz(), tempBtn: sender, tempView: circleView, popDirection: .up)
        self.resetCircleViewButtonBackground(sender)
    }
    func getlowBtnAction(_ sender: UIButton) {
        digitTypeString = BetDigit.low
        self.showTooltip(textMessage: Payout.bigSmall.localiz(), tempBtn: sender, tempView: circleView, popDirection: .up)
        self.resetCircleViewButtonBackground(sender)
    }
    func gethighBtnAction(_ sender: UIButton) {
        digitTypeString = BetDigit.high
        self.showTooltip(textMessage: Payout.bigSmall.localiz(), tempBtn: sender, tempView: circleView, popDirection: .up)
        self.resetCircleViewButtonBackground(sender)
    }
    func getoddBtnAction(_ sender: UIButton) {
        digitTypeString = BetDigit.odd
        self.showTooltip(textMessage: Payout.bigSmall.localiz(), tempBtn: sender, tempView: circleView, popDirection: .up)
        self.resetCircleViewButtonBackground(sender)
    }
    func gettieBtnAction(_ sender: UIButton) {
        digitTypeString = BetDigit.tie
        self.showTooltip(textMessage: Payout.bigSmall.localiz(), tempBtn: sender, tempView: circleView, popDirection: .up)
        self.resetCircleViewButtonBackground(sender)
    }
    func getevenBtnAction(_ sender: UIButton) {
        digitTypeString = BetDigit.even
        self.showTooltip(textMessage: Payout.bigSmall.localiz(), tempBtn: sender, tempView: circleView, popDirection: .up)
        self.resetCircleViewButtonBackground(sender)
    }
    func getmidBtnAction(_ sender: UIButton) {
        digitTypeString = BetDigit.mid
        self.showTooltip(textMessage: Payout.bigSmall.localiz(), tempBtn: sender, tempView: circleView, popDirection: .up)
        self.resetCircleViewButtonBackground(sender)
    }
    //Numbers-
    func getNumberFirstDigitBtnAction(_ sender: UIButton) {
        
        var tempArray = [String]()
        for i in 0..<10 {
            tempArray.append(String(i))
        }
        dropDownObj.anchorView = numberFDButton
        dropDownObj.tag = BetDigit.firstDigitTag
        dropDownObj.setData(btn: numberFDButton, dataSource: tempArray)
        dropDownObj.offsetFromWindowBottom = 10.0
        dropDownObj.show()
        self.resetNumberViewButtonBackground(sender)
        self.showTooltip(textMessage: Payout.numberFistLast.localiz(), tempBtn: sender, tempView: numberView, popDirection: .up)
        self.view.bringSubviewToFront(self.popTip)
    }
    func getNumberLastDigitBtnAction(_ sender: UIButton) {
        self.showTooltip(textMessage: Payout.numberFistLast.localiz(), tempBtn: sender, tempView: numberView, popDirection: .left)
        var tempArray = [String]()
        for i in 0..<10 {
            tempArray.append(String(i))
        }
        dropDownObj.setData(btn: numberFDButton, dataSource: tempArray)
        dropDownObj.anchorView = numberLDButton
        dropDownObj.tag = BetDigit.lastDigitTag
        dropDownObj.show()
        self.resetNumberViewButtonBackground(sender)
    }
    func getNumberTwoDigitBtnAction(_ sender: UIButton) {
        self.showTooltip(textMessage: Payout.numberTwo.localiz(), tempBtn: sender, tempView: numberView, popDirection: .up)
        var tempArray = [String]()
        for i in 0..<100 {
            tempArray.append(twoDigitFormatted(i))
        }
        dropDownObj.anchorView = numberTDButton
        dropDownObj.tag = BetDigit.twoDigitTag
        dropDownObj.setData(btn: numberFDButton, dataSource: tempArray)
        dropDownObj.show()
        self.resetNumberViewButtonBackground(sender)
    }
    func getNumberBothDigitBtnAction(_ sender: UIButton) {
        self.showTooltip(textMessage: Payout.numberBoth.localiz(), tempBtn: sender, tempView: numberView, popDirection: .left)
        var tempArray = [String]()
        for i in 0..<19 {
            tempArray.append(String(i))
        }
        dropDownObj.anchorView = numberBDButton
        dropDownObj.tag = BetDigit.bothDigitTag
        dropDownObj.setData(btn: numberFDButton, dataSource: tempArray)
        dropDownObj.show()
        self.resetNumberViewButtonBackground(sender)
    }
    //Bet confirm /clear
    func getclearamountBtnAction(_ sender: UIButton) { //Cancel
        chiptaotalVlaue = 0
        betVlaueLbl.text = "0"
    }
    func getconfirmBetBtnAction(_ sender: UIButton) { //Confirm
    
        if digitTypeString.isEmpty {
            self.makeToastInBottomWithMessage(AlertField.emptyDigitTypeString)
            return
        }
        if chiptaotalVlaue <= 0 {
            self.makeToastInBottomWithMessage(AlertField.emptyChipValueString)
            return
        }
        if timeLbl.text == Stock.selectTime.localiz() {
            self.makeToastInBottomWithMessage(AlertField.emptyTimeLoopString)
            return
        }
        gameBetRuleString = betDigitString + "-" + digitTypeString
        self.getConfirmStoreBetAPI()
    }
    //MARK: - Reset Button Background -
    func resetCircleViewButtonBackground(_ sender : UIButton)  {
        
        for item in circleView.subviews {
            let tempBtn = item as? UIButton
            //tempBtn?.isSelected = (tempBtn == sender) ? true : false
            if tempBtn == sender {
                tempBtn?.layer.borderWidth = 1.0
                tempBtn?.layer.borderColor = self.stripSelectedView.backgroundColor?.cgColor
            }
            else {
                tempBtn?.layer.borderWidth = 0.0
                tempBtn?.layer.borderColor = UIColor.clear.cgColor
            }
        }
       
    }
    func resetNumberViewButtonBackground(_ sender : UIButton)  {
       
        for item in numberView.subviews {
            let tempBtn = item as? UIButton
            //tempBtn?.isSelected = (tempBtn == sender) ? true : false
            if tempBtn == sender {
                tempBtn?.layer.borderWidth = 1.0
                tempBtn?.layer.borderColor = self.stripSelectedView.backgroundColor?.cgColor
            }
            else {
                tempBtn?.layer.borderWidth = 0.0
                tempBtn?.layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
    //MARK: - Custom Methods -
    func resetBetDetails() -> Void {
        betVlaueLbl.text = "0"
        chiptaotalVlaue = 0
        digitTypeString = ""
    }
    
    func playMouseClickSound()  {
        if mousePlayer != nil {
            mousePlayer?.stop()
            mousePlayer?.play()
        }
        else {
            //Added code for pods
            let bundle = Bundle.init(for: self.classForCoder)
            let path = bundle.path(forResource: AssetResource.mosueClickSound, ofType : AssetName.mp3String)!
            let url = URL(fileURLWithPath : path)
            do {
                mousePlayer = try AVAudioPlayer(contentsOf: url)
                mousePlayer?.play()
                
            } catch {
                print ("Error in music load")
            }
        }
    }
    
    //MARK: - Dropdown Actions -
    @objc func selectfromDropdown(sender : UIButton) {
        self.view.endEditing(true)
        dropDownObj.anchorView = stockView
        if sender.tag == 9 {
            dropDownObj.tag = 9
            dropDownObj.dataSource = [Stock.USStock.localiz(), Stock.ChinaStock.localiz(), Stock.CryptoCurrency.localiz()]
            appDelegate.sharedInstance.dropdownArray = [Stock.USStock, Stock.ChinaStock, Stock.CryptoCurrency]
        }
        else if sender.tag == 10 {
            dropDownObj.tag = 10
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
        else if sender.tag == 11 {
            dropDownObj.tag = 11
            let selectedStock = stockLbl.text?.localiz()
            if selectedStock == Stock.CryptoCurrency.localiz() {
                dropDownObj.dataSource = [Stock.fiveMinutes.localiz(), Stock.oneMinutes.localiz()]
                appDelegate.sharedInstance.dropdownArray = [Stock.fiveMinutes, Stock.oneMinutes]
            }
            else {
                dropDownObj.dataSource = [Stock.fiveMinutes.localiz()]
                appDelegate.sharedInstance.dropdownArray = [Stock.fiveMinutes]
            }
        }
        dropDownObj.show()
    }

    // MARK:- Delegate Method -
    func toggleRoadMapView(isRoadmapExpanded : Bool) {
        if isRoadmapExpanded {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                self.roadMapView.frame.size.height = self.view.frame.size.height-self.chipsCollectionView.bounds.height
                self.roadMapView.bottomTableViewContraint.constant = 20
                self.roadMapView.setCornerRadiusOfView(cornerRadiusValue: 5)
            })
        } else {
            self.roadMapView.frame.size.height = self.view.frame.size.height/4.3
            self.roadMapView.bottomTableViewContraint.constant = 10
        }
    }
    // OpenMenu -
    func openMenuAction(selectedValue: Int, viewController: String) {
        //Added code for pods
        let viewObj = self.getSidemenuStoryBoardSharedInstance().instantiateViewController(withIdentifier: viewController)
        self.navigationController?.pushViewController(viewObj, animated: true)
    }
  
    func refreshDataofRoadmapWithSelecetedType(type: Int) {
        self.roadMapView.firstDigitTableArray = RoadmapManager.createGridArrayForRoadmap(roadmapDataArray: self.roadMapModel!.data![0].roadMap![0].stockData!, withSelectedRoadmapType: type)
        self.roadMapView.roadMapTableView.reloadData()
    }
    
    //Change Language -
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
        updateLocaleClosure?()
    }
    
    //MARK: - Drop Down -
    func creatDropdownNewFile()  {
        
        self.view.bringSubviewToFront(dropDownObj)
        dropDownObj.topOffset = self.view.center
        dropDownObj.width = stockView.frame.width
        dropDownObj.cornerRadius = 10
        dropDownObj.textFont = UIFont.init(name: "Optima", size: 14.0)!
        dropDownObj.textColor = CommonMethods.hexStringToUIColor(hex: Color.dropdownTextColor)
        
        dropDownObj.selectionAction = { [unowned self] (index: Int, item: String) in
            //print("Selected item: \(item) at index: \(index)")
            self.dropDownObj.hide()
            if self.dropDownObj.tag == 9 {
                self.stockLbl.text = appDelegate.sharedInstance.dropdownArray[index].localiz() //item.localiz()
                self.BTULbl.text = Stock.selectBTU.localiz()
                self.timeLbl.text = Stock.selectTime.localiz()
                appDelegate.sharedInstance.selectedStockname = appDelegate.sharedInstance.dropdownArray[index]
            }
            else if self.dropDownObj.tag == 10 {
                self.stockLbl.text = appDelegate.sharedInstance.selectedStockname.localiz()
                self.BTULbl.text = appDelegate.sharedInstance.dropdownArray[index].localiz()
                self.timeLbl.text = Stock.selectTime.localiz()
                appDelegate.sharedInstance.selectedBTUName = appDelegate.sharedInstance.dropdownArray[index]
            }
            else if self.dropDownObj.tag == 11 {
                self.stockLbl.text = appDelegate.sharedInstance.selectedStockname.localiz()
                self.BTULbl.text = appDelegate.sharedInstance.selectedBTUName.localiz()
                self.timeLbl.text = appDelegate.sharedInstance.dropdownArray[index].localiz()
                appDelegate.sharedInstance.selectedTimeLoop = appDelegate.sharedInstance.dropdownArray[index]
                if self.stockLbl.text?.localiz() == Stock.CryptoCurrency.localiz() {
                    if self.timeLbl.text?.localiz() == Stock.oneMinutes.localiz() {
                        self.selectedStockId = "7"
                        self.timeloop = 60
                    }
                    else {
                        self.selectedStockId = "6"
                        self.timeloop = 300
                    }
                }
                else if self.stockLbl.text?.localiz() == Stock.USStock.localiz() {
                    self.selectedStockId = "5"
                    self.timeloop = 300
                }
                else if self.stockLbl.text?.localiz() == Stock.ChinaStock.localiz() {
                    if self.BTULbl.text == Stock.SH000001 {
                        self.selectedStockId = "1"
                        self.timeloop = 300
                    }
                    else if self.BTULbl.text == Stock.SZ399001 {
                        self.selectedStockId = "4"
                        self.timeloop = 300
                    }
                    else if self.BTULbl.text == Stock.SZ399415 {
                        self.selectedStockId = "3"
                        self.timeloop = 300
                    }
                    else if self.BTULbl.text == Stock.SH000300 {
                        self.selectedStockId = "2"
                        self.timeloop = 300
                    }
                }
                //Call to update Stock
                self.getTimerInfoAPI()
                self.getRoadmapDataFromServer(stockID: self.selectedStockId)
                self.getNotificationAPI()
            }
            else if self.dropDownObj.tag == BetDigit.firstDigitTag {
                self.betDigitString = BetDigit.firstdigit
                self.digitTypeString = item
            }
            else if self.dropDownObj.tag == BetDigit.lastDigitTag {
                self.betDigitString = BetDigit.lastdigit
                self.digitTypeString = item
            }
            else if self.dropDownObj.tag == BetDigit.twoDigitTag {
                self.betDigitString = BetDigit.twodigit
                self.digitTypeString = item
            }
            else if self.dropDownObj.tag == BetDigit.bothDigitTag {
                self.betDigitString = BetDigit.bothdigit
                self.digitTypeString = item
            }
        }
    }
    
    //MARK: - Create Tooltip -
    func createTooltipforPayout() -> Void {
        
        popTip.backgroundColor = .red
        popTip.bubbleColor = self.stripSelectedView.backgroundColor ?? .green
        popTip.textColor = .white
    }
    
    //MARK: - Create Charts -
    func createChartView() -> Void {
        chartView.delegate = self
        chartView.layer.borderWidth = 1.0
        chartView.layer.borderColor = UIColor.white.cgColor
        chartView.setViewPortOffsets(left: 0, top: 20, right: 0, bottom: 0)
        chartView.dragEnabled = false
        chartView.setScaleEnabled(false)
        chartView.pinchZoomEnabled = false
        chartView.maxHighlightDistance = 300
        chartView.animate(xAxisDuration: 0.5, easingOption: .easeInCubic)
        chartView.animate(yAxisDuration: 0.5, easingOption: .easeInCubic)
        let yAxis = chartView.leftAxis
        yAxis.labelFont = UIFont(name: "HelveticaNeue-Light", size:12)!
        yAxis.setLabelCount(6, force: false)
        yAxis.labelTextColor = .white
        yAxis.labelPosition = .insideChart
        yAxis.axisLineColor = .white
        chartView.rightAxis.enabled = true
        chartView.legend.enabled = false
        chartView.animate(xAxisDuration: 2, yAxisDuration: 2)
        chartView.backgroundColor = UIColor.clear
        chartView.xAxis.drawAxisLineEnabled = false
        chartView.xAxis.enabled = true
        chartView.xAxis.gridColor = UIColor(red:220/255, green:220/255,blue:220/255,alpha:1)
        chartView.xAxis.gridLineWidth = 0.5
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.drawLabelsEnabled = true
        chartView.xAxis.labelPosition = .top
        chartView.xAxis.labelTextColor = .white
        chartView.xAxis.axisLineColor = .white
        chartView.xAxis.drawLimitLinesBehindDataEnabled = true
        chartView.xAxis.avoidFirstLastClippingEnabled = true
        chartView.backgroundColor = UIColor.clear
        let marker = BalloonMarker(color: UIColor(white: 180/255, alpha: 0.7),
                                   font: .systemFont(ofSize: 11),
                                   textColor: .white,
                                   insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        marker.chartView = chartView
        marker.minimumSize = CGSize(width: 80, height: 40)
        chartView.marker = marker
        chartView.legend.form = .line
        chartView.animate(xAxisDuration: 2.5)
    }
    
    func updateChartData() {
        chartView.data = nil
        let chartDataCount = graphArray?.count ?? 0
        self.setDataCount(Int(chartDataCount), range: UInt32(1000))
        return
    }
    
    func setDataCount(_ count: Int, range: UInt32) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let formatter = LineChartFormatter()
        var xDataPoints = [String]()
        let yVals1 = (0..<count).map { (i) -> ChartDataEntry in
            let val = graphArray![i].PT
            let date = dateFormatter.date(from:graphArray![i].writetime)
            let formatingDate = getFormattedDate(date: date!, format: " HH:mm")
            xDataPoints.append(formatingDate)
            return ChartDataEntry(x: Double(i), y: Double(val)!, data: formatingDate)
        }
        formatter.setValues(values: xDataPoints)
        chartView.xAxis.valueFormatter = formatter
        let set1 = LineChartDataSet(entries: yVals1, label: "DataSet")
        set1.mode = .horizontalBezier
        set1.fillColor = UIColor(red:99/255, green:94/255,blue:154/255,alpha:1)
        let color = UIColor(red:222/255, green:139/255,blue:139/255,alpha:1)
        set1.colors = [color]
        set1.drawCirclesEnabled = false
        set1.drawFilledEnabled = true
        set1.lineWidth = 1.0
        set1.fillAlpha = 1
        set1.cubicIntensity  = 1
        let data = LineChartData(dataSet: set1)
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 9)!)
        data.setDrawValues(false)
        chartView.data = data
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.drawAxisLineEnabled = false
        chartView.xAxis.spaceMin = 0.9
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
    //MARK: - Bet ClsoeView -
    func showBetCloseView() -> Void {
        //Added code for pods
        let bundle = self.initialiseBundle(ClassString: BetCloseView.className())
        betCloseView = bundle.loadNibNamed(BetCloseView.className(), owner: self, options: nil)?[0] as! BetCloseView
        betCloseView.frame = CGRect(x: (self.view.frame.size.width/2) + 72, y: 77, width: (self.view.frame.size.width/2) - 70, height: self.view.frame.size.height-77)
        betCloseView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        betCloseView.layer.masksToBounds = true
        if (self.view.viewWithTag(BetDigit.betCloseViewTag) == nil) {
            self.view.addSubview(betCloseView)
            self.view.bringSubviewToFront(self.sideMenuView)
            self.betCloseView.tag = BetDigit.betCloseViewTag
        }
    }
    
    //MARK: - Timer -
    var timerValue = 0
    func startTimerWithUpdatedValue() -> Void {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimerValue), userInfo: nil, repeats: true)
    }
    @objc func updateTimerValue() {
        
        var closeTime = 0
        for item in self.stockTimerModel!.data! {
            if item.stockId == Int(selectedStockId) {
                closeTime = item.closeTime
                self.BetInterfaceView.isUserInteractionEnabled = (timerValue > (timeloop - closeTime )) ? false : true
                self.BetClearConfirmView.isUserInteractionEnabled = (timerValue > (timeloop - closeTime)) ? false : true
                self.chipsCollectionView.isUserInteractionEnabled = (timerValue > (timeloop - closeTime)) ? false : true
                if timerValue > (timeloop - closeTime + 1 )  {
                    if !self.view.subviews.contains(self.betCloseView) {
                        self.showBetCloseView()
                    }
                }
                else {
                    betCloseView.removeFromSuperview()
                    //print(timerValue - closeTime)
                    if (timerValue - closeTime) == 20 || (timerValue - closeTime) == 180 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                            if !self.getElementFromUserdefaults(UserDefaultsKey.CurrentBetIDs).isEmpty {
                                self.getCurrentBetResultAPI()
                            }
                        })
                    }
                }
                break
            }
        }
        
        if timerValue > 0 {
            timerValue = timerValue - 1
        }
        else {
            timerValue = self.timeloop == 60 ? 60 : 300
            self.getTimerInfoAPI()
            self.getRoadmapDataFromServer(stockID: selectedStockId)
            self.getNotificationAPI()
        }
        let duration  = self.timeFormatted(timerValue)
        if timerValue > (timeloop - closeTime)  {
            stockTimerLbl.font = stockTimerLbl.font.withSize(12)
            stockTimerLbl.text = "Calculating...".localiz()
        }
        else {
            stockTimerLbl.font = stockTimerLbl.font.withSize(20)
            stockTimerLbl.text = duration
        }
    }
    
    //MARK: - Refresh Text for Multi Language support -
    func updateTextOnLanguageChange() -> Void {
        self.gamingLbl.text = NavigationTitle.gamingString.localiz()
        //Buttons
        self.numberFDButton.setmultipleLineTitle(titleString: buttonTitle.numberFirstDigitString.localiz())
        self.numberLDButton.setmultipleLineTitle(titleString: buttonTitle.numberLastDigitString.localiz())
        self.numberTDButton.setmultipleLineTitle(titleString: buttonTitle.numberTwoDigitString.localiz())
        self.numberBDButton.setmultipleLineTitle(titleString: buttonTitle.numberBothDigitString.localiz()) //SUM
        self.FDButton.setmultipleLineTitle(titleString: buttonTitle.firstDigitString.localiz())
        self.LDButton.setmultipleLineTitle(titleString: buttonTitle.lastDigitString.localiz())
        self.TDButton.setmultipleLineTitle(titleString: buttonTitle.twoDigitString.localiz())
        self.BDButton.setmultipleLineTitle(titleString: buttonTitle.bothDigitString.localiz())
        self.numberButton.setmultipleLineTitle(titleString: buttonTitle.numberDigitString.localiz())
        self.bigButton.setTitle(buttonTitle.bigBtnString.localiz(), for: .normal)
        self.smallButton.setTitle(buttonTitle.smallBtnString.localiz(), for: .normal)
        self.oddButton.setTitle(buttonTitle.oddBtnString.localiz(), for: .normal)
        self.evenButton.setTitle(buttonTitle.evenBtnString.localiz(), for: .normal)
        self.lowButton.setTitle(buttonTitle.lowBtnString.localiz(), for: .normal)
        self.highButton.setTitle(buttonTitle.highBtnString.localiz(), for: .normal)
        self.midButton.setTitle(buttonTitle.midBtnString.localiz(), for: .normal)
        self.clearButton.setTitle(buttonTitle.claerBtnString.localiz(), for: .normal)
        self.confirmButton.setTitle(buttonTitle.confirmBtnString.localiz(), for: .normal)
        //Stock
        self.stockLbl.text = appDelegate.sharedInstance.selectedStockname.localiz()
        self.BTULbl.text = appDelegate.sharedInstance.selectedBTUName.localiz()
        self.timeLbl.text = appDelegate.sharedInstance.selectedTimeLoop.localiz()
        //Close Bet
        if self.view.subviews.contains(betCloseView) {
            betCloseView.closeLbl.text = AlertField.betClosedString.localiz()
        }
        //Road Map
        self.roadMapView.firstDigitBtn.setTitle(buttonTitle.roadmapfirstDigitString.localiz(), for: .normal)
        self.roadMapView.lstDigitBtn.setTitle(buttonTitle.roadmaplastDigitString.localiz(), for: .normal)
        self.roadMapView.twoDigitBtn.setTitle(buttonTitle.roadmaptwoDigitString.localiz(), for: .normal)
        self.roadMapView.bothDigitBtn.setTitle(buttonTitle.roadmapbothDigitString.localiz(), for: .normal)
        self.roadMapView.lastDrawTitleLbl.text = buttonTitle.rmLastDrawTitleString.localiz()
        self.roadMapView.winningsTitleLbl.text = buttonTitle.rmTotalWiningTitletString.localiz()
        self.roadMapView.userTitleLbl.text = buttonTitle.rmNoOfuserTitleString.localiz()
        self.roadMapView.resultTitleLbl.text = buttonTitle.rmResultsTitleString.localiz()
        self.roadMapView.roadMapTableView.reloadData()
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
}

// MARK: - CollectionView Chips -
extension GameViewController {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChipsCell.className(), for: indexPath) as! ChipsCell
        cell.titleLbl.text = chipsArray[indexPath.row]
        //Added code for pods
        let selectedImage = UIImage.init(named: AssetName.chipsSelectedString, in: Bundle.init(for: self.classForCoder), compatibleWith: nil)
        let normalImage = UIImage.init(named: AssetName.chipsString, in: Bundle.init(for: self.classForCoder), compatibleWith: nil)
        cell.chipImageView.image = (selelctedRow == indexPath.row) ? selectedImage : normalImage
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chipsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selelctedRow = indexPath.row
        self.chipsCollectionView.reloadData()
        self.playMouseClickSound()
        let chipVlaue = Int(chipsArray[indexPath.row])
        chiptaotalVlaue = chiptaotalVlaue + (chipVlaue ?? 0)
        betVlaueLbl.text = String(chiptaotalVlaue)
    }
}

// MARK: API Call
extension GameViewController {
    /// Getting Stock
    func getStockListAPI() {
        if NetworkManager.sharedInstance.isInternetAvailable(){
            self.showHUD(progressLabel: AlertField.loaderString)
            let stateURL : String = UrlName.baseUrl + UrlName.stockListUrl
            NetworkManager.sharedInstance.commonNetworkCallWithHeader(header: [:], url: stateURL, method: .post, parameters: nil, completionHandler: { (json, status) in
                guard let jsonValue = json else {
                    self.dismissHUD(isAnimated: true)
                    return
                }
                self.stockListModel = Mapper<StockListModel>().map(JSONObject: jsonValue)
                if  self.stockListModel?.code == 200, self.stockListModel!.status {
                    if let list = self.stockListModel?.data, !list.isEmpty {
                    }
                }
                self.dismissHUD(isAnimated: true)
            })
        }else{
            self.showNoInternetAlert()
        }
    }
    //Timer API
    func getTimerInfoAPI() {
        if NetworkManager.sharedInstance.isInternetAvailable(){
            let stateURL : String = UrlName.timerUrl
            NetworkManager.sharedInstance.commonNetworkCallWithHeader(header: [:], url: stateURL, method: .get, parameters: nil, completionHandler: { (json, status) in
                guard let jsonValue = json else {
                    self.dismissHUD(isAnimated: true)
                    return
                }
                self.stockTimerModel = Mapper<StockTimerModel>().map(JSONObject: jsonValue)
                if  self.stockTimerModel?.code == 200, self.stockTimerModel!.status {
                    if let list = self.stockTimerModel?.data, !list.isEmpty {
                        for item in self.stockTimerModel!.data! {
                            if item.stockId == Int(self.selectedStockId) {
                                let tempValue = item.timer
                                if tempValue == -1 {
                                    self.stockTimerLbl.font = self.stockTimerLbl.font.withSize(12)
                                    self.stockTimerLbl.text = "Close".localiz()
                                    self.timer?.invalidate()
                                    self.timer = nil
                                    if self.view.viewWithTag(BetDigit.betCloseViewTag) == nil {
                                        self.showBetCloseView()
                                    }
                                }
                                else {
                                    self.timerValue = tempValue
                                    self.startTimerWithUpdatedValue()
                                }
                                break
                            }
                        }
                    }
                }
                self.dismissHUD(isAnimated: true)
            })
        }else{
            self.showNoInternetAlert()
        }
    }
    // API call for roadmap view
    func getRoadmapDataFromServer(stockID : String) {
        if NetworkManager.sharedInstance.isInternetAvailable(){
            let stateURL : String = UrlName.baseUrl + UrlName.roadmapListUrl
             let params = ["stockId" : stockID]  as [String : Any]
            NetworkManager.sharedInstance.commonNetworkCallWithHeader(header: [:], url: stateURL, method: .post, parameters: params, completionHandler: { (json, status) in
                guard let jsonValue = json else {
                    self.dismissHUD(isAnimated: true)
                    return
                }
                self.roadMapModel = Mapper<RoadmapModel>().map(JSONObject: jsonValue)
                
                if  self.roadMapModel?.code == 200, self.roadMapModel!.status {
                   if let list = self.roadMapModel?.data![0].roadMap![0].stockData, !list.isEmpty {
                    self.graphArray = self.roadMapModel?.data?[0].roadMap![0].stockData
                        self.roadMapModel?.data![0].roadMap![0].stockData = []
                        self.roadMapModel?.data![0].roadMap![0].stockData = RoadmapManager.getLastElements(array: list, count: 30)
                    self.roadMapView.firstDigitTableArray = RoadmapManager.createGridArrayForRoadmap(roadmapDataArray: self.roadMapModel!.data![0].roadMap![0].stockData!, withSelectedRoadmapType: 1)
                    self.roadMapView.lastDrawLbl.text = self.roadMapModel!.data![0].roadMap![0].stockData![(self.roadMapModel?.data![0].roadMap![0].stockData?.count)!-1].PT
                        self.roadMapView.winningsLbl.text = String(self.roadMapModel!.data![0].totalWinning)
                        self.roadMapView.userLbl.text = String(self.roadMapModel!.data![0].totalUsers)
                        self.roadMapView.resultLbl.text = String(self.roadMapModel!.data![0].result)
                    self.lastdrawnFDLbl.text = String(self.roadMapModel!.data![0].roadMap![0].stockData![(self.roadMapModel!.data![0].roadMap![0].stockData!.count)-1].no1)
                    self.lastdrawnLDLbl.text = String(self.roadMapModel!.data![0].roadMap![0].stockData![(self.roadMapModel!.data![0].roadMap![0].stockData!.count)-1].no2)
                        self.roadMapView.roadMapTableView.reloadData()
                        self.updateChartData()
                    } 
                }
                self.dismissHUD(isAnimated: true)
            })
        }else{
            self.showNoInternetAlert()
        }
    }
    
    //Confirm Bet API
    func getConfirmStoreBetAPI() {
        if NetworkManager.sharedInstance.isInternetAvailable(){
            self.setViewInteractionEnabled(false)
            self.showHUD(progressLabel: AlertField.loaderString)
            let betURL : String = UrlName.baseUrl + UrlName.storeBetUrl + UrlName.API_Token
            
            let tempArray = ["gameRule": gameBetRuleString, "amount": chiptaotalVlaue, "stockId": "7", "loop": "1"] as [String : Any]
            let param = ["data" : [tempArray]]
            NetworkManager.sharedInstance.commonNetworkCallWithHeader(header: [:], url: betURL, method: .post, parameters: param, completionHandler: { (json, status) in
                guard let jsonValue = json else {
                    self.dismissHUD(isAnimated: true)
                    return
                }
                self.storeBetModel = Mapper<StoreBetModel>().map(JSONObject: jsonValue)
                if  self.storeBetModel?.code == 200, self.storeBetModel!.status {
                    if let list = self.storeBetModel?.data, !list.isEmpty {
                        self.makeToastInBottomWithMessage(AlertField.betDoneString)
                        let currentBetId = list[0].betId
                        if !self.getElementFromUserdefaults(UserDefaultsKey.CurrentBetIDs).isEmpty {
                            let previousBetIds = self.getElementFromUserdefaults(UserDefaultsKey.CurrentBetIDs)
                            let updatedBetIds = previousBetIds + "," + currentBetId
                            UserDefaults.standard.setValue(updatedBetIds, forKey: UserDefaultsKey.CurrentBetIDs)
                        }
                        else {
                            UserDefaults.standard.setValue(currentBetId, forKey: UserDefaultsKey.CurrentBetIDs)
                        }
                    }
                }
                else {
                    self.makeToastInBottomWithMessage(self.storeBetModel?.message.capitalized ?? "")
                }
                self.resetBetDetails()
                self.setViewInteractionEnabled(true)
                self.dismissHUD(isAnimated: true)
            })
        }else{
            self.showNoInternetAlert()
        }
    }
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
                        self.userCreditLbl.text = "$" + String(self.notificationModel?.userBalance ?? 0)
                        self.showNotifications()
                    }
                }
                else {
                    //self.makeToastInBottomWithMessage(self.notificationModel?.message.capitalized ?? "")
                }
            })
        }else{
            //self.showNoInternetAlert()
        }
    }
    //CurrentBet Result -
    func getCurrentBetResultAPI() {
        if NetworkManager.sharedInstance.isInternetAvailable(){
            if self.getElementFromUserdefaults(UserDefaultsKey.CurrentBetIDs).isEmpty {
                return
            }
            let betURL : String = UrlName.baseUrl + UrlName.currentBetResultUrl
            let betIds = self.getElementFromUserdefaults(UserDefaultsKey.CurrentBetIDs)
            let params = ["betId" : betIds]
            print("Pararms = \(params)")
            NetworkManager.sharedInstance.commonNetworkCallWithHeader(header: [:], url: betURL, method: .post, parameters: params, completionHandler: { (json, status) in
                self.removeElementFromUserdefaults(UserDefaultsKey.CurrentBetIDs) //Remove saved bet Ids
                guard let jsonValue = json else {
                    self.dismissHUD(isAnimated: true)
                    return
                }
                self.currentBetResultModel = Mapper<CurrentBetResultModel>().map(JSONObject: jsonValue)
                if  self.currentBetResultModel?.code == 200, self.currentBetResultModel!.status {
                    if let list = self.currentBetResultModel?.data, !list.isEmpty {
                        //Update notification button color
                       
                        for items in list {
                            print("=== \(items.results) ===")
                            if items.results == 0 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                    UIView.animate(withDuration: 1.0) {
                                        self.bellButton.renderColorOnImage("notificationIcon", imageColor: CommonMethods.hexStringToUIColor(hex: Color.btnRedColor))
                                    }
                                })
                            }
                            else if items.results == 1 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                    UIView.animate(withDuration: 1.0) {
                                        self.bellButton.renderColorOnImage("notificationIcon", imageColor: CommonMethods.hexStringToUIColor(hex: Color.btnGreenColor))
                                    }
                                })
                            }
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(list.count)*2, execute: {
                            UIView.animate(withDuration: 1.0) {
                                self.bellButton.renderColorOnImage("notificationIcon", imageColor: CommonMethods.hexStringToUIColor(hex: Color.btnWhiteColor))
                            }
                        })
                    }
                }
            })
        }
    }
}

extension GameViewController {
    
    func getFormattedDate(date: Date, format: String) -> String {
            let dateformat = DateFormatter()
            dateformat.dateFormat = format
            return dateformat.string(from: date)
    }
}

@objc(LineChartFormatter)
public class LineChartFormatter: NSObject, IAxisValueFormatter {
    var names = [String]()
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return names[Int(value)]
    }
    public func setValues(values: [String]) {
        self.names = values
    }
}

//MARK: - Show Chart Tooltip -
class PillMarker: MarkerImage {
    
    private (set) var color: UIColor
    private (set) var font: UIFont
    private (set) var textColor: UIColor
    private var labelText: String = ""
    private var attrs: [NSAttributedString.Key: AnyObject]!
    
    static let formatter: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.allowedUnits = [.minute, .second]
        f.unitsStyle = .short
        return f
    }()
    
    init(color: UIColor, font: UIFont, textColor: UIColor) {
        self.color = color
        self.font = font
        self.textColor = textColor
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        attrs = [.font: font, .paragraphStyle: paragraphStyle, .foregroundColor: textColor, .baselineOffset: NSNumber(value: -4)]
        super.init()
    }
    
    override func draw(context: CGContext, point: CGPoint) {
        // custom padding around text
        let labelWidth = labelText.size(withAttributes: attrs).width + 10
       
        
        // if you modify labelHeigh you will have to tweak baselineOffset in attrs
        let labelHeight = labelText.size(withAttributes: attrs).height + 4
        
        // place pill above the marker, centered along x
        var rectangle = CGRect(x: point.x, y: point.y, width: labelWidth, height: labelHeight)
        rectangle.origin.x -= rectangle.width / 2.0
        let spacing: CGFloat = 20
        rectangle.origin.y -= rectangle.height + spacing
        
        // rounded rect
        let clipPath = UIBezierPath(roundedRect: rectangle, cornerRadius: 6.0).cgPath
        context.addPath(clipPath)
        context.setFillColor(UIColor.white.cgColor)
        context.setStrokeColor(UIColor.black.cgColor)
        context.closePath()
        context.drawPath(using: .fillStroke)
        
        // add the text
        labelText.draw(with: rectangle, options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
    }
    
    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        labelText = customString(entry.y)
    }
    
    private func customString(_ value: Double) -> String {
        let formattedString = PillMarker.formatter.string(from: TimeInterval(value))!
        // using this to convert the left axis values formatting, ie 2 min
        return "\(formattedString)"
    }
}
//MARK: - Auto Hide tooltip -
extension GameViewController {
    
    func showTooltip(textMessage : String, tempBtn : UIButton, tempView : UIView, popDirection : PopTipDirection) {
        self.createTooltipforPayout()
        popTip.backgroundColor = .red
        popTip.show(text: textMessage, direction: popDirection, maxWidth: 200, in: tempView, from: tempBtn.frame)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            self.popTip.hide()
        })
    }
}

//MARK: - UICollectionViewCell -
class ChipsCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLbl : UILabel!
    @IBOutlet weak var chipImageView : UIImageView!
    override func awakeFromNib() {
        
    }
}

extension DropDown {
    
    func setData(btn: UIButton?, dataSource: [String]){
        guard let btn = btn else { return }
        self.semanticContentAttribute = .unspecified
        self.anchorView = btn
        self.bottomOffset = CGPoint(x: 0, y: btn.bounds.height)
        self.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
            cell.optionLabel.textAlignment = .center
        }
        self.dataSource = dataSource
    }
}
