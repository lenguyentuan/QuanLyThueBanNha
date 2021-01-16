using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using QuanLyThueNha.DAL;

namespace QuanLyThueNha
{
  public partial class Dang_nhap : Form
  {
    public Dang_nhap()
    {
      InitializeComponent();
    }

    // Thoát đăng nhập
    private void btnLoginExit_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
    {
      Application.Exit();
    }

    // chuyển đến đăng ký
    private void linkSignUp_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
    {
      var SignUpForm = new Dang_ky();
      SignUpForm.ShowDialog();
    }

    // đăng nhập
    private void btnLogin_Click(object sender, EventArgs e)
    {
      string userName = tbxLoginUsername.Text, pw = tbxLoginpw.Text;
      if(userName == "" || pw == "")
      {
        MessageBox.Show("Vui lòng nhập đầy đủ thông tin.");
        return;
      }
   
      // đăng nhập
      int roleLogin = (int)DataProvider.Instance.ExecutScalarSql($@"EXEC [dbo].[sp_login] @userName = '{userName}', @pw = '{pw}'");
     
      if (roleLogin == -1)
      {
        // đăng nhập thất bại
        MessageBox.Show("Tài khoản hoặc mật khẩu không đúng.");
        return;
      }
      else
      {
        // đăng nhập thành công
        MessageBox.Show("Đăng nhập thành công");
        this.Hide();
        if (roleLogin == 1)
        {
          // admin role
          var AdminForm = new Admin();
          AdminForm.ShowDialog();
        }
        else
        {
          var UserForm = new User();
          UserForm.ShowDialog();
        }  
      }
    }
  }
}
