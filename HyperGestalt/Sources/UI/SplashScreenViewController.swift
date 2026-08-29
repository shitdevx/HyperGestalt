import UIKit

class SplashScreenViewController: UIViewController {
    var onSplashComplete: (() -> Void)?
    
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "hypergestalt_logo")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var versionLabel: UILabel = {
        let label = UILabel()
        label.text = "Version 1.0.0"
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor.secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.systemBackground
        view.addSubview(logoImageView)
        view.addSubview(loadingIndicator)
        view.addSubview(versionLabel)
        
        setupConstraints()
        
        loadingIndicator.startAnimating()
        
        // Simulate initialization delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.onSplashComplete?()
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 120),
            logoImageView.heightAnchor.constraint(equalToConstant: 120),
            
            loadingIndicator.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 24),
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            versionLabel.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 8),
            versionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
}