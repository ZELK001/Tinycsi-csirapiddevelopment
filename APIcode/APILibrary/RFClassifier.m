Factor = TreeBagger(nTree, train_data, train_label);
[Predict_label,Scores] = predict(Factor, test_data);