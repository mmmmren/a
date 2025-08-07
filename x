# 1. 安装 React Native 环境
npx react-native init HydrocephalusApp
cd HydrocephalusApp
npm install react-navigation react-navigation-stack react-navigation-tabs
npm install @react-native-community/async-storage

// App.js (用户登录页面)
import React, { useState } from 'react';
import { View, TextInput, Button, Text, StyleSheet } from 'react-native';
import AsyncStorage from '@react-native-community/async-storage';

const LoginPage = ({ navigation }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleLogin = async () => {
    if (email && password) {
      try {
        await AsyncStorage.setItem('user', email); // 模拟用户登录
        navigation.navigate('TestPage'); // 登录后跳转到测试页面
      } catch (error) {
        console.error('Error storing user data:', error);
      }
    } else {
      alert('请输入邮箱和密码');
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.header}>登录</Text>
      <TextInput
        style={styles.input}
        placeholder="请输入邮箱"
        value={email}
        onChangeText={setEmail}
      />
      <TextInput
        style={styles.input}
        placeholder="请输入密码"
        secureTextEntry
        value={password}
        onChangeText={setPassword}
      />
      <Button title="登录" onPress={handleLogin} />
    </View>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  header: { fontSize: 24, marginBottom: 20 },
  input: { width: 250, height: 40, borderColor: 'gray', borderWidth: 1, marginBottom: 15, paddingLeft: 10 },
});

export default LoginPage;

// TestPage.js (6-MWT 测试页面)
import React, { useState, useEffect } from 'react';
import { View, Text, Button, StyleSheet } from 'react-native';
import { useNavigation } from '@react-navigation/native';

const TestPage = () => {
  const [startTime, setStartTime] = useState(null);
  const [elapsedTime, setElapsedTime] = useState(0);
  const navigation = useNavigation();

  useEffect(() => {
    let interval;
    if (startTime) {
      interval = setInterval(() => {
        setElapsedTime(Math.floor((Date.now() - startTime) / 1000));
      }, 1000);
    }
    return () => clearInterval(interval);
  }, [startTime]);

  const handleStartTest = () => {
    setStartTime(Date.now());
  };

  const handleEndTest = () => {
    clearInterval();
    alert(`测试结束，行走时间: ${elapsedTime} 秒`);
    navigation.navigate('RiskAssessment', { elapsedTime });
  };

  return (
    <View style={styles.container}>
      <Text style={styles.header}>6分钟步行测试</Text>
      <Text>已走时间：{elapsedTime} 秒</Text>
      <Button title="开始测试" onPress={handleStartTest} />
      <Button title="结束测试" onPress={handleEndTest} disabled={!startTime} />
    </View>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  header: { fontSize: 24, marginBottom: 20 },
});

export default TestPage;

# 1. 初始化 Node.js 项目
mkdir backend
cd backend
npm init -y
npm install express body-parser mysql2

// server.js (后端API)
const express = require('express');
const bodyParser = require('body-parser');
const mysql = require('mysql2');

const app = express();
const port = 3000;

// 创建MySQL连接
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: 'password',
  database: 'hydrocephalus'
});

// 连接到数据库
db.connect((err) => {
  if (err) throw err;
  console.log('数据库连接成功');
});

// 中间件
app.use(bodyParser.json());

// 用户注册接口
app.post('/register', (req, res) => {
  const { name, email, age } = req.body;
  const query = 'INSERT INTO users (name, email, age) VALUES (?, ?, ?)';
  db.query(query, [name, email, age], (err, result) => {
    if (err) {
      res.status(500).json({ message: '注册失败' });
    } else {
      res.status(200).json({ message: '注册成功' });
    }
  });
});

// 获取用户信息接口
app.get('/user/:email', (req, res) => {
  const email = req.params.email;
  const query = 'SELECT * FROM users WHERE email = ?';
  db.query(query, [email], (err, result) => {
    if (err) {
      res.status(500).json({ message: '获取用户信息失败' });
    } else {
      res.status(200).json(result[0]);
    }
  });
});

// 启动服务器
app.listen(port, () => {
  console.log(`服务器运行在 http://localhost:${port}`);
});

-- 创建用户表
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  age INT,
  gender VARCHAR(10)
);

-- 创建步态测试结果表
CREATE TABLE gait_test (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  walk_distance FLOAT,
  walk_speed FLOAT,
  walk_time INT,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 创建MMSE测试结果表
CREATE TABLE mmse_result (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  score INT,
  date_tested DATETIME,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

