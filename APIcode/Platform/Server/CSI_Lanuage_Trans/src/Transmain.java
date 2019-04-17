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
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;

import javax.swing.JButton;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.filechooser.FileSystemView;

public class Transmain extends JFrame {

	static JButton submit = new JButton("提交代码");
	static JButton startTrans = new JButton("开始转换");
	static JButton check = new JButton("查看生成m脚本");
	static JButton startadjust = new JButton("开始运行m脚本并调参");
	String path = null;
	String DesktopPath = null;
	String newmfilePath = null;
	String csifunctuion = null;
	static JTextArea showArea = new JTextArea();

	public Transmain() {

		showArea.append("启动程序" + "\n");
		setTitle("代码转化程序");
		setSize(600, 400);
		showArea.setEditable(false);
		JLabel timechange = new JLabel();
		add(timechange, BorderLayout.NORTH);
		JScrollPane jslp = new JScrollPane(showArea); // 加滚动条
		jslp.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
		showArea.setFont(new Font("楷体", Font.PLAIN, 16));
		showArea.setForeground(Color.black);
		JPanel control = new JPanel();

		control.setLayout(new GridLayout(1, 4));
		control.add(submit);
		control.add(startTrans);
		control.add(check);
		control.add(startadjust);
		add(jslp, BorderLayout.CENTER);
		add(control, BorderLayout.SOUTH);
		// 选择要转化的文件
		submit.addActionListener(new ActionListener() {

			@Override
			public void actionPerformed(ActionEvent e) {
				int result = 0;
				File file = null;
				JFileChooser fileChooser = new JFileChooser();
				FileSystemView fsv = FileSystemView.getFileSystemView(); // 注意了，这里重要的一句
				// System.out.println(fsv.getHomeDirectory()); // 得到桌面路径
				DesktopPath = fsv.getHomeDirectory().getPath();
				System.out.println("桌面路径是" + DesktopPath); // 得到桌面路径
				fileChooser.setCurrentDirectory(fsv.getHomeDirectory());
				fileChooser.setDialogTitle("请选择要上传的文件...");
				fileChooser.setApproveButtonText("确定");
				fileChooser.setFileSelectionMode(JFileChooser.FILES_ONLY);
				result = fileChooser.showOpenDialog(fileChooser);
				if (JFileChooser.APPROVE_OPTION == result) {
					path = fileChooser.getSelectedFile().getPath();
					System.out.println("读取文件的路径path: " + path);
				}
			}
		});
		// 开始转换
		startTrans.addActionListener(new ActionListener() {

			@Override
			public void actionPerformed(ActionEvent e) {

				try {
					String encoding = "GBK";
					File file = new File(path);
					// 初始化一些全局变量
					String a[] = { "addpath('APILibrary');\n", "addpath('toolScripts');\n", "global f;\n",
							"global count;\n", "global csiSubc;\n", "global varSilent;\n", "count=0;\n",
							"varSilent=0;\n", "csiSubc=0;\n" };
					// 生成的m脚本保存路径，（两种，1.生成到桌面上。2。生成到当前文件夹下）
					// File new_mfile = new File(DesktopPath + "/CSInewfile.m");
					// newmfilePath = new String(DesktopPath + "/CSInewfile.m");
					File new_mfile = new File("CSInewfile.m");
					newmfilePath = new String("CSInewfile.m");

					if (!new_mfile.exists()) {
						try {

							System.out.println("m脚本文件不存在，开始创建");
							new_mfile.createNewFile();

						} catch (IOException e1) {
							// TODO Auto-generated catch block
							e1.printStackTrace();
						}
					}

					FileWriter fw = new FileWriter(new_mfile, false);
					BufferedWriter bufw = new BufferedWriter(fw);

					if (file.isFile() && file.exists()) { // 判断文件是否存在
						InputStreamReader read = new InputStreamReader(new FileInputStream(file), encoding);// 考虑到编码格式
						BufferedReader bufferedReader = new BufferedReader(read);
						String lineTxt = null;

						while ((lineTxt = bufferedReader.readLine()) != null) {
							System.out.println(lineTxt);
							if (lineTxt.indexOf("main_function") != -1) {

								int begin = lineTxt.indexOf("main_function");
								String temp = lineTxt.substring(begin + 14);
								// 添加函数名
								// temp = "function ret=" + temp + "(handles)\n";
								temp = "function ret=" + "CSInewfile" + "(handles)\n";
								csifunctuion = temp;
								bufw.write(temp);
								bufw.newLine();
								// 添加初始化变量
								for (int k = 0; k < a.length; k++) {
									bufw.write(a[k]);
									bufw.newLine();
								}
								// 添加读取fifo文件模块
								bufw.write("Openfile('csififo.fifo');\n");
								bufw.newLine();

							} else if (lineTxt.indexOf("CSI_sampleSetting") != -1) {
								// 暂时还没想好怎么写
							} else if (lineTxt.indexOf("loop()") != -1) {

								bufw.write("while 1\n");
								bufw.newLine();
							} else if (lineTxt.indexOf("CSI_IntrusionTest_oneChannelThreshold") != -1) {
								bufw.write("IntrusionTest_oneChannelThreshold(handles,15,5,5,1);\n");
								bufw.newLine();
							}
						}

						bufw.write("end\n");
						bufw.newLine();
						bufw.write("fclose(f);\n");
						bufw.newLine();
						bufw.write("end\n");
						bufw.newLine();
						read.close();
						bufw.close();
						fw.close();
						// 至此已生成完成m脚本文件，如果需要生成GUI文件，调用生成GUI的函数

						GetGUI();
					} else {
						System.out.println("找不到指定的文件");
					}
				} catch (UnsupportedEncodingException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				} catch (FileNotFoundException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				} catch (IOException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}
			}
		});

		// 查看转换后的文件
		check.addActionListener(new ActionListener() {

			@Override
			public void actionPerformed(ActionEvent e) {
				try {
					Runtime.getRuntime().exec("notepad " + newmfilePath);
				} catch (IOException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				} // 修改这里的1.txt为你自己的文本文件名
			}
		});

		// 调用shell脚本启动GUI程序
		startadjust.addActionListener(new ActionListener() {

			@Override
			public void actionPerformed(ActionEvent e) {
				new Thread() {
					@Override
					public void run() {
						try {
							File directory = new File("");
							String testString = directory.getCanonicalPath();
							String shpath = testString + "/Start_Adjust_All.sh";
							Process ps;
							ps = Runtime.getRuntime().exec(shpath);
							if (ps == null) {
								JOptionPane.showMessageDialog(null, "文件不存在", "脚本不存在", JOptionPane.ERROR_MESSAGE);
							}
							ps.waitFor();
							showArea.append("调用完毕" + "\n");
						} catch (IOException | InterruptedException e1) {
							// TODO Auto-generated catch block
							e1.printStackTrace();
						}
					}
				}.start();
			}
		});

		// 防止只要点击主窗口小红叉就关闭主窗口
		// Frame窗口的小红叉默认就是点击就关闭，所以无论你选择什么它都会关闭，一定要当前窗口的构造函数里添加一句话
		// frame.setDefaultCloseOperation(JFrame.DO_NOTHING_ON_CLOSE);否则点击取消也会关闭窗口：
		setDefaultCloseOperation(JFrame.DO_NOTHING_ON_CLOSE);
		// 添加窗口关闭事件
		addWindowListener(new WindowAdapter() {
			public void windowClosing(WindowEvent e) {
				int selection = JOptionPane.showConfirmDialog(Transmain.this, "您要退出吗？", "提示",
						JOptionPane.OK_CANCEL_OPTION, JOptionPane.QUESTION_MESSAGE);
				if (selection == JOptionPane.OK_OPTION) {
					System.exit(0);

				} else {
					// setVisible(true);
				}
			}
		});
		setLocationRelativeTo(null); // 居中显示
		setResizable(false);// 窗口不可调节大小
		setVisible(true);// 让容器可显示
	}

	public static void main(String[] args) throws Exception {
		new Transmain();

	}

	public void GetGUI() throws IOException {
		// 标准的GUI文件
		File file = new File("guiStandard.m");
		String encoding = "GBK";
		// 结合csifunction生成的GUI文件
		File new_guifile = new File("myguitest.m");

		if (!new_guifile.exists()) {
			try {

				System.out.println("GUI脚本文件不存在，开始创建");
				new_guifile.createNewFile();

			} catch (IOException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		}
		FileWriter fw = new FileWriter(new_guifile, false);
		BufferedWriter bufw = new BufferedWriter(fw);

		if (file.isFile() && file.exists()) { // 判断文件是否存在
			InputStreamReader read = new InputStreamReader(new FileInputStream(file), encoding);// 考虑到编码格式
			BufferedReader bufferedReader = new BufferedReader(read);
			String lineTxt = null;
			while ((lineTxt = bufferedReader.readLine()) != null) {

				if (lineTxt.indexOf("%recorder(gcf,handles);") != -1) {

					bufw.write("CSInewfile(handles);\n");
					bufw.newLine();
				} else {

					bufw.write(lineTxt);
					bufw.newLine();
				}

			}
			// 千万注意要有close()操作，不然无法将内容写入文本当中
			read.close();
			bufw.close();
			fw.close();
		}
	}

}
