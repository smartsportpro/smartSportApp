//
//  loginView.swift
//  smartSport
//
//  Created by Geovanni Parra on 10/19/25.
//

import SwiftUI

struct loginScreenView: View {
    @State private var email: String = ""
    @State private var password: String = ""
        
    var body: some View {
        VStack(spacing: 20) {
            Text("Smart Sport ")
                .position(x: 150, y: 100)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 90)
            
            // Email TextField
            TextField("Email", text: $email)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            // Password SecureField
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            // Login Button
            Button("Login") {
                // Handle login action here
                print("Email: \(email)")
                print("Password: \(password)")
            }
            // Sign up button
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.black)
            .foregroundColor(.orange)
            .cornerRadius(8)
            .disabled(email.isEmpty || password.isEmpty)
            
            Button("Sign up") {
                print("Email: \(email)")
                print("Password: \(password)")
            }
            
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.black)
            .foregroundColor(.orange)
            .cornerRadius(8)
            .disabled(email.isEmpty || password.isEmpty)

            NavigationLink("Forgot Password?") {
                    ForgotPasswordView()
                }
                .font(.footnote)
                .foregroundColor(.blue)
                .padding(.top, 10)
            
            Spacer()
        }
        .padding(50)
        .background(.orange)
    }
    }

    #Preview {
        loginScreenView()
    }

