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
            Text("Login")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 30)
            
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
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(email.isEmpty || password.isEmpty)
            
            Spacer()
        }
        .padding(30)
        .background(.orange)
    }
    }

    #Preview {
        loginScreenView()
    }

