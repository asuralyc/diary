import SwiftUI

struct PasswordVerificationView: View {
    @State private var enteredPassword = ""
    @State private var attempts = 0
    @State private var showingAlert = false
    @State private var isLocked = false
    let onPasswordVerified: () -> Void
    
    private let maxAttempts = 3
    
    var body: some View {
        VStack(spacing: 30) {
            if isLocked {
                VStack(spacing: 20) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                    
                    Text("🔒 日記已鎖定")
                        .font(.title)
                        .fontWeight(.semibold)
                    
                    Text("密碼錯誤次數過多")
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "lock.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.indigo)
                    
                    VStack(spacing: 8) {
                        Text("解鎖日記")
                            .font(.title)
                            .fontWeight(.semibold)
                        
                        Text("請輸入密碼以存取您的日記")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        if attempts > 0 {
                            Text("剩餘嘗試次數：\(maxAttempts - attempts)")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    VStack(spacing: 16) {
                        SecureField("密碼", text: $enteredPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.title3)
                            .onSubmit {
                                verifyPassword()
                            }
                        
                        Button {
                            verifyPassword()
                        } label: {
                            Text("解鎖")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(enteredPassword.isEmpty ? Color.gray : Color.indigo)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .disabled(enteredPassword.isEmpty)
                    }
                }
            }
        }
        .padding(40)
        .background(Color(.systemBackground))
        .alert("密碼錯誤", isPresented: $showingAlert) {
            Button("確定", role: .cancel) {}
        } message: {
            Text("請檢查您的密碼並重試")
        }
    }
    
    private func verifyPassword() {
        let savedPassword = UserDefaults.standard.string(forKey: "appPassword") ?? ""
        
        if enteredPassword == savedPassword {
            onPasswordVerified()
        } else {
            attempts += 1
            enteredPassword = ""
            
            if attempts >= maxAttempts {
                isLocked = true
            } else {
                showingAlert = true
            }
        }
    }
}

#Preview {
    PasswordVerificationView {
        print("Password verified!")
    }
}