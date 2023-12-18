import torch
import torch.nn as nn
from torchvision import transforms, models
from collections import defaultdict
import matplotlib.pyplot as plt
from PIL import Image
device = torch.device('cpu')
import json
import os
import random


en2ru = {}
with open('clean_ingred.txt', 'r') as f:
  en=f.readlines()
with open('rus_clean_ingred.txt', 'r',encoding='utf-8') as f:
  ru=f.readlines()

for e, r in zip(en, ru):
  en2ru[e.rstrip('\n')] = r.rstrip('\n')
with open('en2ru_ing.json', 'w') as f:
  json.dump(en2ru, f)


with open('clean_ingred.txt', 'r') as f:
  clean_ingredients = list(f.read().split('\n'))
  print(len(clean_ingredients))

id2word = defaultdict()
for i, ingr in enumerate(clean_ingredients):
  id2word[i+1] = ingr

rus_id2word = defaultdict()
for i, ingr in enumerate(clean_ingredients):
  rus_id2word[i+1] = ingr

word2id = {v:k for k,v in id2word.items()}
def words2ids(ingreds):
  return [word2id[ing] for ing in ingreds]

model = models.densenet161(pretrained=True)

def init_model():

    for param in model.parameters():
        param.requires_grad = False
    num_feat = model.classifier.in_features

    model.classifier = nn.Sequential(
        nn.Linear(num_feat, 1024),
        nn.BatchNorm1d(1024),
        nn.ReLU(),
        nn.Linear(1024, 512),
        nn.BatchNorm1d(512),
        nn.ReLU(),
        nn.Linear(512, len(word2id)),
        nn.Sigmoid())
    model.to(device)

    model.load_state_dict(torch.load("model_encoder_classifier_best.pth",map_location=torch.device('cpu')))
    model.eval()

# Функция для выбора случайного изображения из указанной папки
def get_random_image(folder_path):
    images = os.listdir(folder_path)
    random_image = random.choice(images)
    return os.path.join(folder_path, random_image)

# Функция для загрузки случайного изображения, предсказания ингредиентов и вывода результатов
def predict_random_image_from_folder(folder_path, transform):
    random_image_path = get_random_image(folder_path)
    print("Случайно выбранное изображение:", random_image_path)

    # Отображение выбранного изображения
    with torch.no_grad():
        img = Image.open(random_image_path).convert('RGB')
    plt.figure(figsize=(12, 8))
    plt.imshow(img)
    plt.axis('off')
    plt.show()


    # Получение предсказания ингредиентов
    img = transform(img).to(device).unsqueeze(0)
    ingred_pred = model(img) > 0.3
    ingred_pred = ingred_pred.nonzero()[:, 1].tolist()

    # Обработка предсказанных индексов, чтобы убедиться, что они не выходят за пределы словаря
    valid_ingred_pred = [ing for ing in ingred_pred if ing + 1 in id2word]
    ingred_pred = [id2word[ing + 1] for ing in valid_ingred_pred]
    ingred_pred = [en2ru[ing] for ing in ingred_pred]

    # Вывод предсказанных ингредиентов на русском языке
    print("Предсказанные ингредиенты:")
    print('\t' + '\n\t'.join(ingred_pred))


# Путь к папке с изображениями
folder_path = r'random img'

# Вызов функции для предсказания случайного изображения из папки
predict_random_image_from_folder(folder_path, transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
]))
