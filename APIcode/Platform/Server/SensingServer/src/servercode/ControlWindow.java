package servercode;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Font;
import java.awt.GridLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.net.Socket;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;

/*
 * 功能：服务器端弹出模拟入侵窗口，向安卓端发送入侵信息
 *      添加读取文件操作，可以从matlab处理得到的fifo文件中读取数据，并向Android发送通知
 */

public class ControlWindow extends JFrame {
	private Socket socket;// 通信套接字
	private BufferedReader sin;
	private PrintWriter sout;// 发出指令
	private String username;

	JLabel showStateInfo = new JLabel("");

	// 获得读入字符串函数
	public String getString(BufferedReader sin) throws IOException {
		try {
			String str = sin.readLine();
			return str;
		} catch (Exception e) {
			if (e instanceof java.net.SocketException) {
				setVisible(false);
			}
		}
		return null;
	}

	public ControlWindow(String name, Socket s) throws IOException {

		this.socket = s;
		this.username = name;

		showStateInfo.setOpaque(true);
		showStateInfo.setBackground(Color.WHITE);
		sin = new BufferedReader(new InputStreamReader(s.getInputStream()));
		sout = new PrintWriter(new BufferedWriter(new OutputStreamWriter(this.socket.getOutputStream())), true);
		setTitle("控制窗口");
		setSize(300, 300);
		JPanel mJPanel = new JPanel();
		mJPanel.setLayout(new GridLayout(3, 1));
		JLabel showInfo = new JLabel("用户名：" + username, JLabel.CENTER);
		JButton GetCSI = new JButton("开始采集CSI");
		JButton StopCSI = new JButton("停止采集CSI");

		// 设置字体
		showInfo.setOpaque(true);
		showInfo.setFont(new Font("楷体", Font.PLAIN, 18));
		showInfo.setBackground(Color.WHITE);

		mJPanel.add(showInfo);
		mJPanel.add(GetCSI);
		mJPanel.add(StopCSI);

		add(mJPanel, BorderLayout.CENTER);

		// 开始采集CSI
		GetCSI.addActionListener(new ActionListener() {

			@Override
			public void actionPerformed(ActionEvent e) {
				// TODO Auto-generated method stub
				sout.println("get_csi");
				sout.flush();
				System.out.println("开始采集CSI\n");
			}

		});

		// 停止采集CSI
		StopCSI.addActionListener(new ActionListener() {

			@Override
			public void actionPerformed(ActionEvent e) {
				// TODO Auto-generated method stub
				sout.println("stop_get_csi");
				sout.flush();
				System.out.println("停止采集CSI\n");

			}
		});

		// System.out.println(txt2String(file));
		setDefaultCloseOperation(JFrame.DO_NOTHING_ON_CLOSE);
		// 添加窗口关闭事件
		addWindowListener(new WindowAdapter() {
			public void windowClosing(WindowEvent e) {
				int selection = JOptionPane.showConfirmDialog(ControlWindow.this, "您要断开连接并退出吗？", "提示",
						JOptionPane.OK_CANCEL_OPTION, JOptionPane.QUESTION_MESSAGE);
				if (selection == JOptionPane.OK_OPTION) {
					try {
						sout.close();
						socket.close();
						System.out.println(username + "(服务器端)关闭套接字,退出控制" + "\n");

						// 写入日志，动作：(服务器端)关闭套接字,退出控制
						setVisible(false);
					} catch (IOException e1) {
						// TODO Auto-generated catch block
						e1.printStackTrace();
					}
				}
			}

		});

		// 接受安卓端信息的线程,用于判断套接字是否正常
		// new Thread() {
		// @Override
		// public void run() {
		// try {
		// while (true) {
		// String result;
		// result = getString(sin);
		// if (result == null) {
		// // 写入日志，动作：退出控制
		// System.out.println(username + "(安卓端)关闭套接字,退出控制" + "\n");
		// testdb.onlineUser_do(username, 1);// 从上线表中删去即将下线的用户
		// setVisible(false);
		// break;
		// }
		// }
		// } catch (IOException e) {
		// // TODO Auto-generated catch block
		// e.printStackTrace();
		// }
		// }
		// }.start();

		setResizable(false);// 设置窗口不可调节大小
		setLocationRelativeTo(null); // 居中显示
	}

}
