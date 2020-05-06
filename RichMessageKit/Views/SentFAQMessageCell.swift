//
//  SentFAQMessageView.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 04/06/19.
//

import UIKit

/// FAQMessageCell for sender side.
///
/// It contains `FAQMessageView` and `SentMessageView`
/// It also contains `Config` which is used to configure views properties. Values can be changed for customizations.
public class SentFAQMessageCell: UITableViewCell {
    // MARK: Public properties

    /// Configuration to adjust padding and maxWidth for the view.
    public struct Config {
        public static var padding = Padding(left: 60, right: 10, top: 10, bottom: 10)
        public static var maxWidth = UIScreen.main.bounds.width
        public static var faqTopPadding: CGFloat = 4
        public static var faqLeftPadding: CGFloat = 20
        public enum StateView {
            public static var width: CGFloat = 17.0
            public static var height: CGFloat = 9.0
        }

        public enum TimeLabel {
            /// Left padding of `TimeLabel` from `StateView`
            public static var leftPadding: CGFloat = 2.0
            public static var maxWidth: CGFloat = 200.0
            public static var rightPadding: CGFloat = 2.0
        }
    }

    // MARK: Fileprivate properties

    fileprivate var timeLabel: UILabel = {
        let lb = UILabel()
        lb.setStyle(MessageTheme.sentMessage.time)
        lb.isOpaque = true
        return lb
    }()

    fileprivate var stateView: UIImageView = {
        let sv = UIImageView()
        sv.isUserInteractionEnabled = false
        sv.contentMode = .center
        return sv
    }()

    fileprivate lazy var timeLabelWidth = timeLabel.widthAnchor.constraint(equalToConstant: 0)
    fileprivate lazy var timeLabelHeight = timeLabel.heightAnchor.constraint(equalToConstant: 0)

    fileprivate lazy var messageView = SentMessageView(
        frame: .zero,
        padding: messageViewPadding,
        maxWidth: Config.maxWidth
    )

    fileprivate lazy var faqView = FAQMessageView(
        frame: .zero,
        faqStyle: FAQMessageTheme.sentMessage,
        alignLeft: false
    )

    fileprivate var messageViewPadding: Padding

    fileprivate lazy var messageViewHeight = messageView.heightAnchor.constraint(equalToConstant: 0)

    static let faqWidth = Config.maxWidth - Config.faqLeftPadding - Config.padding.right

    // MARK: Initializer

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        messageViewPadding = Padding(left: Config.padding.left,
                                     right: Config.padding.right,
                                     top: Config.padding.top,
                                     bottom: Config.faqTopPadding)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        setupConstraints()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods

    /// It updates `SentFAQMessageCell`. Sets FAQmessage, text message, time, status.
    ///
    /// - Parameter model: `FAQMessage` used to update the cell.
    public func update(model: FAQMessage) {
        guard model.message.isMyMessage else {
            print("😱😱😱Inconsistent information passed to the view.😱😱😱")
            print("For Sender view isMyMessage should be true")
            return
        }
        if model.message.isMessageEmpty() {
            messageViewHeight.constant = 0
            messageView.updateHeightOfView(hideView: true, model: model.message.text)

        } else {
            messageView.update(model: model.message)
            messageViewHeight.constant = SentMessageView.rowHeight(model: model.message, maxWidth: Config.maxWidth, padding: messageViewPadding)
            messageView.updateHeightOfView(hideView: false, model: model.message.text)
        }

        // Set time and update timeLabel constraint.
        timeLabel.text = model.message.time
        let timeLabelSize = model.message.time.rectWithConstrainedWidth(Config.TimeLabel.maxWidth,
                                                                        font: MessageTheme.sentMessage.time.font)
        timeLabelHeight.constant = timeLabelSize.height.rounded(.up)
        timeLabelWidth.constant = timeLabelSize.width.rounded(.up) // This is amazing😱😱😱... a diff in fraction can trim.
        layoutIfNeeded()

        faqView.update(model: model, maxWidth: SentFAQMessageCell.faqWidth)
        /// Set frame
        let height = SentFAQMessageCell.rowHeight(model: model)
        frame.size = CGSize(width: Config.maxWidth, height: height)

        guard let status = model.message.status else { return }
        // Set status
        var statusImage = MessageTheme.sentMessage.status
        switch status {
        case .pending:
            statusImage.pending = statusImage.pending?.withRenderingMode(.alwaysTemplate)
            stateView.image = statusImage.pending
            stateView.tintColor = UIColor.red
        case .sent:
            stateView.image = statusImage.sent
        case .delivered:
            stateView.image = statusImage.delivered
        case .read:
            statusImage.read = statusImage.read?.withRenderingMode(.alwaysTemplate)
            stateView.image = statusImage.read
            stateView.tintColor = UIColor(netHex: 0x0578FF)
        }
    }

    /// It's used to get the exact height of cell.
    ///
    /// - Parameter model: `FAQMessage` used for updating the cell.
    /// - Returns: Exact height of cell.
    public class func rowHeight(model: FAQMessage) -> CGFloat {
        return FAQMessageSizeCalculator().rowHeight(model: model, maxWidth: Config.maxWidth, padding: Config.padding)
    }

    // MARK: - Private helper methods

    private func setupConstraints() {
        addViewsForAutolayout(views: [messageView, faqView, stateView, timeLabel])

        NSLayoutConstraint.activate([
            messageView.topAnchor.constraint(equalTo: topAnchor),
            messageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            messageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            messageViewHeight,

            faqView.topAnchor.constraint(equalTo: messageView.bottomAnchor, constant: Config.faqTopPadding),
            faqView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Config.faqLeftPadding),
            faqView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Config.padding.right),
            faqView.bottomAnchor.constraint(equalTo: timeLabel.topAnchor, constant: -1 * Config.padding.bottom),
            stateView.widthAnchor.constraint(equalToConstant: Config.StateView.width),
            stateView.heightAnchor.constraint(equalToConstant: Config.StateView.height),
            stateView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1 * Config.padding.bottom),
            stateView.leadingAnchor.constraint(greaterThanOrEqualTo: faqView.leadingAnchor, constant: Config.padding.left),
            stateView.trailingAnchor.constraint(equalTo: faqView.trailingAnchor, constant: -1 * Config.TimeLabel.leftPadding),

            timeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1 * Config.padding.bottom),
            timeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: stateView.leadingAnchor, constant: Config.TimeLabel.leftPadding),
            timeLabelWidth,
            timeLabelHeight,
            timeLabel.trailingAnchor.constraint(equalTo: stateView.leadingAnchor, constant: -1 * Config.TimeLabel.rightPadding),
        ])
    }
}
