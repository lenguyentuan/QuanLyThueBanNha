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
  public partial class Dang_ky : Form
  {
    public Dang_ky()
    {
      InitializeComponent();
    }

    // thoát đăng ký
    private void btnSignupExit_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
    {
      this.Close();
    }

    // đăng ký
    private void btnSignup_Click(object sender, EventArgs e)
    {
      try
      {
        String userName = tbxSignupUsername.Text;
        String pw = tbxSignupPw.Text, confirmPw = tbxSignupConfirmPw.Text;
        if (userName == "" || pw == "" || confirmPw == "")
        {
          MessageBox.Show("Vui lòng nhập đủ thông tin !");
          return;
        }
        // mật khẩu không khớp
        if (pw != confirmPw)
        {
          MessageBox.Show("Mật khẩu không khớp !");
          return;
        }
        // mật khẩu quá ngắn
        if (pw.Length < 6)
        {
          MessageBox.Show("Mật khẩu ít nhất 6 ký tự");
          return;
        }
        int result = DataProvider.Instance.ExecuteNoQuerySql($@"EXEC [dbo].[sp_signup] @userName = '{userName}', @pw = '{pw}'");
        // Đăng ký thành công
        if (result == 1) {
          MessageBox.Show("Đăng ký thành công.");
          var LoginForm = new Dang_nhap();
          LoginForm.Show();
          this.Hide();
        }
        else
        {
          MessageBox.Show("Đăng ký thất bại.");
          return;
        }
      }
      catch (Exception ex)
      {
        MessageBox.Show("Tài khoản đã tồn tại");
      }
    }

    // chuyển đến đăng nhập
    private void linkToLogin_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
    {
      this.Hide();
      var Login = new Dang_nhap();
      Login.ShowDialog();
    }
  }
}
