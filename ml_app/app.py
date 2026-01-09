import streamlit as st
import joblib
import pandas as pd
import matplotlib.pyplot as plt
from transformers import (SpecialityGrouper, ProcedureGrouper, MeanDaysByGrouper)


# page config
st.set_page_config(page_title="Risk Prediction", page_icon=":robot:")
st.title(":hospital: Mortality Risk Prediction")
st.markdown(
    """
    Estimate the probability of in-hospital mortality at admission
    for patients hospitalized due to Primary Care Sensitive Conditions (PCSCs).
    """
)

# side bar
with st.sidebar:
    st.header("Risk classification App")
    st.image("docs/sus.webp")
    st.markdown(
        "## How to use\n"
        "1. Input patient clinical data. \n"
        "2. Click the prediction button. \n"
        "3. Check risk classification."
    )
    st.markdown("---")
    st.markdown("# About")
    st.markdown("The machine learn model used here was trained on SIH/SUS data from the Brazilian Minitry of Health.")

# session state
if "risk_proba" not in st.session_state:
    st.session_state.risk_proba = None
    st.session_state.risk_class = None

# load files (cached)
@st.cache_resource
def load_model():
    return joblib.load("ml_app/model.joblib")

@st.cache_data
def load_data():
    final_data = joblib.load("ml_app/final_data.joblib")
    features = joblib.load("ml_app/features_option.joblib")
    procedure_rank = joblib.load("ml_app/procedure_rank.joblib")
    roc_curve = joblib.load("ml_app/roc_curves.joblib")
    return final_data, features, procedure_rank, roc_curve

model = load_model()
final_data, features, procedure_rank, roc_curve = load_data()

# risk prediction simulation
st.header(":vertical_traffic_light: Patient risk simulation")

# options
disease_options = features["disease_category"]
procedure_options = procedure_rank.loc[procedure_rank["count"] >= 600, "procedure"].tolist()
region_options = features["big_region_name"]
bed_options = features["bed_speciality"]
complexity_options = features["complexity"]

with st.form("risk_form"):
    col1, col2, col3 = st.columns(3)

    with col1:
        region = st.selectbox("Region", region_options)
        disease = st.selectbox("Disease category", disease_options)
        bed = st.selectbox("Bed speciality", bed_options)
        
    with col2:
        sex = st.selectbox("Sex", ["Male", "Female"])
        procedure = st.selectbox("Procedure", procedure_options)
        

    with col3:
        age = st.number_input("Age", min_value=0, max_value=120, value=60)
        complexity = st.selectbox("Complexity", complexity_options)
    
    submitted = st.form_submit_button("Predict risk")

# prediction
if submitted:
    # create simulation df
    df = pd.DataFrame([{
        "big_region_name": region,
        "gender": sex,
        "age": age,
        "disease_category": disease,
        "bed_speciality": bed,
        "complexity": complexity,
        "procedure": procedure,
        "total_hosp_days": 0 
    }])

    risk_proba = model.predict_proba(df)[0, 1]

    if risk_proba < 0.20:
        risk_class = "Low risk"
    elif risk_proba < 0.40:
        risk_class = "Moderate risk"
    elif risk_proba < 0.60:
        risk_class = "High risk"
    else:
        risk_class = "Imminent risk"

    st.session_state.risk_proba = risk_proba
    st.session_state.risk_class = risk_class

# prediction output
risk_icon_color = {
    "Low risk": {"icon": "🟢", "color": "#2ecc71"},
    "Moderate risk": {"icon": "🟡", "color": "#f1c40f"},
    "High risk": {"icon": "🟠", "color": "#e67e22"},
    "Imminent risk": {"icon": "🔴", "color": "#e74c3c"}
}

if st.session_state.risk_proba is not None:
    meta = risk_icon_color[st.session_state.risk_class]
    col_a, col_b = st.columns(2)

    with col_a:
        st.metric(
            label="Predicted mortality risk",
            value=f"{st.session_state.risk_proba:.1%}"
        )

    with col_b:
        st.metric(
            label="Risk classification",
            value=f"{meta['icon']} {st.session_state.risk_class}"
        )

# model explanation
# expander
exp1 = st.expander(":bar_chart: Model explanation & performance")
# tabs for each part
tab_data, tab_roc, tab_summary = exp1.tabs(["Data", "Roc Curve", "Model Summary (SHAP)"])

# data table
with tab_data:
    st.dataframe(final_data, hide_index=True)

# roc curve
with tab_roc:
    # colors and order of the curves
    roc_colors = {"train": "#5e3c99", "test": "#e66101", "oot": "#008837"}
    order = ["train", "test", "oot"]
    
    # multiselect
    splits = st.multiselect("Select curve", options=["train", "test", "oot"], default=["oot"])

    fig, ax = plt.subplots()
    for split in order:
        if split in splits:
            ax.plot(roc_curve[split]["fpr"], roc_curve[split]["tpr"], color=roc_colors[split],
                label=f"{split.upper()} (AUC = {roc_curve[split]['auc']:.3f})"
            )

    ax.plot([0, 1], [0, 1], linestyle="--", color="black", label="Chance (AUC = 0.5)")
    ax.set_xlabel("False Positive Rate")
    ax.set_ylabel("True Positive Rate")
    ax.set_title("ROC Curve – LightGBM")
    ax.legend()
    ax.grid(True)
    st.pyplot(fig)

# shap summary 
with tab_summary:
    st.image(
        "docs/shap_summary.png",
        caption="SHAP summary plot (global feature importance)",
        use_container_width=True
    )

# more information
# expander
exp2 = st.expander(":eyes: More information")
exp2.markdown(
        "#### For more information of how this works:\n"
        "* Check the Machine Learning code in the [HTML page](https://019b9fc6-5626-8f65-e0a1-60f288c3886a.share.connect.posit.cloud/).\n"
        "* Check the Analytical Report of the Brazilian PCSCs in the [HTML page](https://019b9fc9-cbf8-b008-71ab-3a23a796c9aa.share.connect.posit.cloud/).\n"
        "* Check the code source reporsitory on [Github](https://github.com/arcarvalhojr/sih-sus_analysis_project/tree/main)."
    )





